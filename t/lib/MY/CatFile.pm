package MY::CatFile;
use 5.010;
use strict;
use warnings;
use parent qw(Exporter);
use Carp;
use FindBin;
use File::Spec;
our @EXPORT = qw(cat);

=pod

=head1 NAME

MY::CatFile - delegate for file read operations

=head1 SYNOPSIS

  use MY::CatFile;  # explicit import
  use MY::Stuff;    # implicit import

  {
     local %ENV = %ENV;
     delete $ENV{FILE_SRC};
     # fread(3) is used
     my $web_mf = cat('web', 'package.json');

     $ENV{FILE_SRC} = 'index';
     # git-cat-file(1) is used on git index (stage 0)
     my $top_mf = cat('package.json');

     $ENV{FILE_SRC} = 'odb';
     # git-cat-file(1) is used on git object database
     my $pkg_mf = cat('api', 'pyproject'toml);
  }

=head1 DESCRIPTION

=over

=item cat

Read a file in its entirety and return the contents.
Path components are joined using C<catfile> from L<File::Spec>
when reading from disk, or the Unix path delimiter C</> when
reading from Git.  Croak if file not found.  In the case of
reading from disk, croak if file is not readable.  In the case
of reading from Git, croak if L<git(1)> is not executable, if
L<git-cat-file(1)> is unable to print contents of a file due to
any error (most commonly, due to missing file), or if there is
any pipe read error.

This subroutine is exported by default.

=item $ROOT

The root directory of the source tree.  Defaults to the current
directory, but you may set it using C<$MY::CatFile::ROOT>.

=back

=head1 ENVIRONMENT

=over

=item FILE_SRC

Where C<cat> should read files from.  The C<disk> location
starts from the root of the source tree (three directories above
this one, to be as VCS-neutral as possible).  The C<index> location
reads from the Git index (stage 0).  The C<odb> location reads from
the Git object database by following the tree at HEAD.

=back

=cut

our $ROOT = '.';

my ($cat_pid, $cat_rdr, $cat_wtr);

sub open_cat
{
	require IPC::Open2;
	$cat_pid = IPC::Open2::open2($cat_rdr, $cat_wtr,
		'git', '--literal-pathspecs', -C => $ROOT,
		'cat-file', '--batch', '-Z'
	);
}

END {
	if ($cat_pid) {
		# close pipe
		close $cat_wtr or warn "cat-file STDIN did not close cleanly: $!";
		close $cat_rdr or warn "cat-file STDOUT did not close cleanly: $!";
		# reap child
		my $wait_ret = waitpid($cat_pid, 0);
		$wait_ret == $cat_pid or warn "could not reap cat-file "
			. "child $cat_pid (wait returned $wait_ret)";
		($cat_wtr, $cat_rdr, $cat_pid) = (undef) x 3;
	}
}

# Revspec for HEAD tree and index; see gitrevisions(7)
my %GIT_PLACES = (
	odb => 'HEAD:',
	index => ':0:',
);

sub cat
{
	my $sauce = $ENV{FILE_SRC} // 'disk';
	if ($sauce eq 'disk') {
		local $/;  # -0777
		my $file = File::Spec->catfile($ROOT, @_);

		open my $fh, '<', $file or croak "open on-disk $file: $!";
		binmode $fh;

		my $data = <$fh>;
		defined $data or croak "read on-disk $file: @{[eof ? 'EOF' : $!]}";

		close $fh or carp "close on-disk $file: $!";
		return $data;
	}
	my $place = $GIT_PLACES{$sauce} or croak "invalid FILE_SRC: $sauce";
	my $pathspec = $place . join '/' => @_;
	open_cat or die "could not fork cat-file: $!\n" unless $cat_pid;
	local $/ = chr 0;

	print $cat_wtr $pathspec, $/ or croak "cat-file $pathspec: pipe write: $!";
	$cat_wtr->flush;
	# Check feof(3); the $! on an EOF read may be misleading (...
	# even though some fread(3)s hang more often than report $! in
	# practice.  See "Re: Best way to handle readline errors?":
	# <https://www.perlmonks.org/?node_id=583456>)
	defined (my $info = <$cat_rdr>) or croak "cat-file $pathspec: "
		. "pipe read: @{eof ? 'EOF' : qq[$!]}";
	chomp $info;

	unless ($info =~ /\A([[:xdigit:]]+) (blob|tree|tag|commit|submodule)(?: ([[:digit:]]+))?\z/) {
		# looks like: "cat-file: (missing|excluded|ambiguous)"...
		$info =~ s/\A\Q$pathspec\E//;
		croak "cat-file $pathspec$info";
	}
	my ($oid, $type, $size) = ($1, $2, $3);
	$type eq 'blob' or croak "cat-file $pathspec: expecting blob, got $type";

	# Read blob content (with basic integrity checks)
	my ($data, $real, $hash);
	defined ($data = do { local $/ = \$size; <$cat_rdr> })
		or croak "cat-file $pathspec: pipe read: @{[eof ? 'EOF' : $!]}";
	($real = length $data) == $size
		or croak "cat-file $pathspec: expected size $size, read $real";
	($hash = hash_object($type, $size, $data) // $oid) eq $oid
		or croak "cat-file $pathspec: bad oid $oid (got $hash)";

	# git-cat-file(1) terminates the object content with a null byte.
	my $trailer;
	defined ($trailer = do { local $/ = \1; <$cat_rdr> })
		or croak "cat-file $pathspec: pipe read: @{[eof ? 'EOF' : $!]}";
	$trailer eq chr 0 or croak "cat-file $pathspec: bad EOF byte "
		. "(expected char 0x00, got 0x@{[sprintf '%02X', ord $trailer]}";
	$data
}

# INFO is cached per-repository (source tree); on the other hand,
# $GIT_HAS_CONFIG_SUBCMD is global since there is only ONE Git :)
my (%INFO, $GIT_HAS_CONFIG_SUBCMD);

sub hash_object
{
	my ($type, $size, $data) = @_;
	require Digest::SHA;

	my $ctx = do {
		#
		# GIT-CONFIG(1):
		# CONFIGURATION FILE
		#    Variables
		#        extensions.*
		#            Unless otherwise stated, is an error to specify an extension
		#            if core.repositoryFormatVersion is not 1. See gitrepository-
		#            layout(5).
		# 
		#            objectFormat
		#                Specify the hash algorithm to use. The acceptable values
		#                are sha1 and sha256. If not specified, sha1 is assumed.
		#
		my $repo_version = git_config_get('core.repositoryFormatVersion');
		if ($repo_version == 0) {
			Digest::SHA->new(1)  # All version 0 repositories use SHA-1
		}
		elsif ($repo_version == 1) {
			my $odb_format = git_config_get('extensions.objectFormat') // 'sha1';
			if ($odb_format eq 'sha1') {
				Digest::SHA->new(1)
			}
			elsif ($odb_format eq 'sha256') {
				Digest::SHA->new(256)
			}
			else {
				croak "warning: $ROOT: unknown for version 1 "
					. "repository: $odb_format\n"
			}
		}
		else {
			carp "warning: $ROOT: unknown repository version: "
				. $repo_version . ", skipping integrity check\n";
			return
		}
	};
	my $NIL = chr 0; $ctx->add("$type $size$NIL")->add($data)->hexdigest
}

# Adopted from my cs400:bin/init-subtree
#
## Turns out we have been using a rather modern version of Git
## that turned git config's set/get etc. operations into subcommands
## of the git-config subcommand (the man page changed too - sneaky!)
##
## I did a git blame and googled the name of the branch that
## got merged ('ps/config-subcommands') and found these guys:
##
## Release notes: https://git.kernel.org/pub/scm/git/git.git/tree/Documentation/RelNotes/2.46.0.txt?h=v2.46.0~162
##  * The operation mode options (like "--get") the "git config" command
##    uses have been deprecated and replaced with subcommands (like "git
##    config get").
## (commit v2.46.0~162 = 19fe900cfce8096b7645ec9611a0b981f6bbd154)
## (blob 6d7fee5501c005e0966b6f5e9849d6d3e52ea88c line 30-35)
## Pull Request: https://lore.kernel.org/all/cover.1709724089.git.ps@pks.im/
## (commit v2.46.0~169 = fe3ccc7aab61dbc2837ba11bed122dc2f74045e3)
## (second parent 7b91d310ce21aa663e025c8955c46c49ab037a41)
##
sub git_config_get
{
	my ($key) = @_;
	# note the use of "exists"; if we've looked up the key and
	# it does not exist, the non-existence itself is cached
	unless (exists $INFO{$ROOT}{config}{$key}) {
		my @CMD = ( 'git', -C => $ROOT, 'config',
			git_has_config_subcmd()
			? qw( get ) : ()
		);
		push @CMD, '--', $key;

		require IPC::Open2;
		my $pid = IPC::Open2::open2(my $rdr, my $wtr, @CMD);
		close $wtr;
		chomp (my $value = <$rdr>);
		$pid == waitpid($pid, 0) or die "wait git-config: $!";
		my $wstat = $?;
		my $estat = $wstat >> 8;

		# ret=0, Get OK
		if ($estat == 0) {
			$INFO{$ROOT}{config}{$key} = $value;
		}
		# ret=1, Key does not exist
		elsif ($estat == 1) {
			$INFO{$ROOT}{config}{$key} = undef;
		}
		else {
			croak("git-config died with exit status $estat (wstat $wstat)");
		}
	}
	$INFO{$ROOT}{config}{$key}
}

# cs400:bin/init-subtree again
#
## on parsing git version...
## https://stackoverflow.com/a/67811664
## $ git cat-file blob v2.30.0:help.c | nl -ba | sed -n 646,654p
##    646	void get_version_info(struct strbuf *buf, int show_build_options)
##    647	{
##    648		/*
##    649		 * The format of this string should be kept stable for compatibility
##    650		 * with external projects that rely on the output of "git version".
##    651		 *
##    652		 * Always show the version, even if other options are given.
##    653		 */
##    654		strbuf_addf(buf, "git version %s\n", git_version_string);
##
sub git_has_config_subcmd
{
	unless (defined $GIT_HAS_CONFIG_SUBCMD) {
		chomp (my $version = `git version`);
		$? == 0 or die "git died with wait status $?";

		unless ($version =~ /^git version (.+)$/) {
			die "cannot parse git version: $_\n";
		}

		my ($major, $minor) = split /[.]/, $1;

		$GIT_HAS_CONFIG_SUBCMD = $major >= 2 && $minor >= 46;
	}
	$GIT_HAS_CONFIG_SUBCMD
}

1; # keep require happy

__END__

=pod

=head1 SEE ALSO

L<File::Spec>,
L<git-cat-file(1)>,
L<gitrevisions(7)>,
L<gittutorial-2(7)>

=cut
