#!perl
use File::Spec;
use FindBin;
(my $name = $0) =~ s/\Q.install\E$// or die "E: I cannot be invoked as $0 because it doesn't end with *.install.\n";
(undef, undef, $name) = File::Spec->splitpath($name);  # a less gnarly version of $0 =~ m!\b([^/]+)\.[^\.]+\z!
chomp (my $nonbare = `git rev-parse --is-inside-work-tree`);
$? == 0 or die "E: git died with wait status $? (are you in a git repository?)\n";
$nonbare eq 'true' or die "E: $name hook is useless in a bare repository.\n";
chomp (my $GITDIR = `git rev-parse --git-dir`);
my $dst = File::Spec->catfile($FindBin::Bin, $name);
my $pwd = File::Spec->catfile($GITDIR, 'hooks');
my $src = File::Spec->catfile($GITDIR, 'hooks', $name);
if (-l $src) {
	unlink $src or warn "warning: unlink $src: $!\n"
}
my $rel = File::Spec->abs2rel($dst, $pwd);
# Sadly <= is a relational operator and not a comma
symlink $rel, $src or die "E: symlink $dst <= $src: $!\n";
print STDERR "+ ln -sf $rel $src\n" if grep { $_ eq '-v' } @ARGV;
