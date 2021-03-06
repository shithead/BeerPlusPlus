package BeerPlusPlus::Test::Database;

use strict;
use warnings;

use feature 'say';


=head1 NAME

BeerPlusPlus::Test::Database - module for testing modules which use the
database module internally

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

  # initialize an empty test database
  use BeerPlusPlus::Test::Database;

  # load the module to test which uses the database module
  Test::More;
  BEGIN { use_ok('BeerPlusPlus::Module') }

  # work with the module as usual...

=head1 DESCRIPTION

Sets the database module's variable C<DATADIR> to a temporary directory.
The modules must be C<use>d before the module which uses the database
module is loaded since the datadir is fix after including the module.
This module is intended for test purposes only since the data get lost
after the application terminated.

=cut


use BeerPlusPlus::Database;
use Carp;
use File::Basename;
use File::Temp 'tempdir';


=head2 SUBROUTINES

=over 4

=item reset_datadir()

Sets the database module's C<DATADIR> variable to a temporary directory
which is removed after the test terminated. This subroutine is called once
during this module is loaded.

=cut

sub reset_datadir() {
	my $template = 'db.XXXXXXX';
	my $tempdir = tempdir($template, DIR => dirname($0), CLEANUP => 1);

	croak("insufficient permissions for tempdir '$tempdir'")
			unless -r $tempdir and -w $tempdir and -x $tempdir;

	$BeerPlusPlus::Database::DATADIR = $tempdir;
}

=back

=cut


# TODO set signal handlers which remove directory if test is aborted

reset_datadir();


1;
__END__

=head1 AUTHOR

8ware, E<lt>8wared@googlemail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Innercircle

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

