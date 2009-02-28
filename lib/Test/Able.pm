package Test::Able;

use 5.008;
use Moose;
use Moose::Exporter;
use Moose::Util::MetaRole;
use Test::Able::Object;

=head1 NAME

Test::Able - xUnit with Moose

=head1 VERSION

0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

 package MyTest;

 use Test::Able; # only because Test::Able->import must run
 extends qw( Test::Able );
 use Test::More;

 startup          some_startup  => sub { ... };
 setup            some_setup    => sub { ... };
 test plan => 1,  foo           => sub { ok( 1 ); };
 test plan => 42, bar           => sub { ok( 1 ) for 1 .. 42; };
 teardown         some_teardown => sub { ... };
 shutdown         some_shutdown => sub { ... };

 package main;

 use MyTest;

 MyTest->new->run_tests;

=head1 DESCRIPTION

An xUnit style testing framework inspired by Test::Class and built using
Moose.  It can do all the important things Test::Class can do and more.  The
prime advantages of using this module instead of Test::Class are flexibility
and power.  Namely, Moose.

This module was created for a few of reasons:

=over

=item *

To address perceived limitations in, and downfalls of, Test::Class.

=item *

To leverage existing Moose expertise for testing.

=item *

To bring Moose to the Perl testing game.

=back

The core code and documentation are in L<Test::Able::Object>.

=head1 METHODS

=cut

my ( $import, $unimport, ) = Moose::Exporter->build_import_methods(
    with_caller => [
        qw( startup setup test teardown shutdown ),
    ],
    also => 'Moose',
);
*unimport = $unimport;

my $ran_import;
sub import {
    my ( $class, ) = @_;
    unless ( $ran_import ) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class              => $class,
            metaclass_roles        => [ 'Test::Able::Object', ],
            method_metaclass_roles => [ 'Test::Able::Method', ],
        );
        $ran_import++;
    }

    goto &{ $import };
}

sub BUILD {
    my ( $self, ) = @_;

    $self->meta->current_test_object( $self, );
    $self->meta->build_all_methods;
    $self->meta->clear_current_test_object;

    return;
}

=over

=item run_tests

A convenience method around L<Test::Able::Object/run_tests>.  Can be called as
a class or instance method.

=cut

sub run_tests {
    my ( $proto, ) = @_;

    my $self = ref $proto ? $proto : $proto->new;
    $self->meta->current_test_object( $self, );
    $self->meta->run_tests;
    $self->meta->clear_current_test_object;

    return;
}

=item startup/setup/test/teardown/shutdown

A more Moose-like way to do method declaration.  The syntax is similar to
L<Moose/has> except its for test-related methods.

These start with one of startup/setup/test/teardown/shutdown depending on
what type of method you are defining.  Then comes any attribute name/value
pairs to set in the L<Test::Able::Method> object.  The last pair must always
be the method name and the coderef.  This is to disambiguate between
the method name/code pair and another attribute in Test::Able::Method that
happens to take a coderef.  Here are some examples:

setup some_setup_method => sub { ... };
test do_setup => 0, do_teardown => 0, some_test_method => sub { ... };
shutdown foo => sub { ... }, bar => undef => baz => 42,
  some_shutdown_method => sub { ... };

=back

=cut

sub startup  { return __add_method( type => 'startup',  @_, ); }
sub setup    { return __add_method( type => 'setup',    @_, ); }
sub test     { return __add_method( type => 'test',     @_, ); }
sub teardown { return __add_method( type => 'teardown', @_, ); }
sub shutdown { return __add_method( type => 'shutdown', @_, ); }

sub __add_method {
    my $class = splice( @_, 2, 1, );
    my ( $code, $name, ) = ( pop, pop, );

    my $meta = Moose::Meta::Class->initialize( $class, );
    $meta->add_method( $name, $code, );

    if ( @_ ) {
        my $method = $meta->get_method( $name, );
        my %args = @_;
        while ( my ( $k, $v ) = each %args ) {
            $method->$k( $v );
        }
    }

    return;
}

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
