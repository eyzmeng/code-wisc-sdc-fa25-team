#!perl
# Check consistency between corepack package managers
use Encode;
use File::Spec::Functions qw(catfile updir);
use FindBin;
use JSON::PP; # qw(decode_json)
use Test::More tests => 1;

use lib catfile($FindBin::Bin, 'lib');
use MY::Stuff;
$MY::CatFile::ROOT = catfile($FindBin::Bin, updir);

my $top_mf = 'package.json';
my $web_mf = 'web/package.json';

note "top-level package.json is $top_mf";
my $top_cp = decode_json(encode "UTF-8", cat split '/' => $top_mf)->{packageManager};

note "Svelte package.json is $web_mf";
my $web_cp = decode_json(encode "UTF-8", cat split '/' => $web_mf)->{packageManager};

is($top_cp => $web_cp, "packageManager in-sync");
