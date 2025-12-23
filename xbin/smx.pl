#!/usr/bin/env perl

use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw( gnu_compat bundling permute no_getopt_compat );
GetOptions(
	'm=s@' => \my @mesg,
	'n|nono' => \my $nono,
) or die "usage: $0 [-m MESG] [-n|--nono] [--] ...\n";

my @options;

push @options, map { -m => $_ } @mesg;
push @options, '-n' if $nono;
# Extension to store-meta, where we recognize that mirrored
# meta-refs are, in fact, semantically volatile in nature too.
push @options, '--grep-tree' => (<<'PERL');
    return !1   if length($name) == 0;         # empty filename
    return !2   if length($name) =~ /[\0\/]/;  # NUL in filename
    return !3   if $name eq '.';               # git-fsck hasDot
    return !4   if $name eq '..';              # git-fsck hasDotDot
    return !5   if $name eq '.git';            # git-fsck hasDotgit
    return !6   if $path eq 'objects';    # object database
    return !7   if $path eq 'refs/info'   # meta-references
       ||( !8   ,  $path =~ m'^refs/mirrors/([^/]+|[^/]+/.*[.]git)/refs/info$'n
    ); !!9;     # The End
PERL
push @options, '--grep-blob' => (<<'PERL');
    no warnings 'void';
    2;; if ($path eq 'info/refs') {
    3;; 	return !(m@^[[:xdigit:]]+\11(refs/mirrors/([^/]+|[^/]+/.*[.]git)/)?refs/info(/|$)@n);
    4;; }
    5;; if ($path eq 'packed-refs') {
    6;; 	return !(m@^[[:xdigit:]]+[ ](refs/mirrors/([^/]+|[^/]+/.*[.]git)/)?refs/info(/|$)@n);
    7;; }
    !!8;   # The End
PERL

exec <~/tree/utils/store-meta>, @options, '--', @ARGV;
die "execve: $!\n";
