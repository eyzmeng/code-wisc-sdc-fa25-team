package MY::Stuff;
use 5.010;
use strict;
use warnings;
use parent qw(Exporter);
our @EXPORT = qw(cat);

use MY::CatFile qw(cat);

1; # keep require happy

__END__

=head1 NAME

MY::Stuff - common utilities for repository sanity testing

=head1 SYNOPSIS

  use MY::Stuff;

=head1 DESCRIPTION

A module that imports everything in the L<"SEE ALSO"> section.

=head1 SEE ALSO

C<MY::CatFile>
