package Test::Able;

use 5.008;
use Moose;
use Moose::Util::MetaRole;
use Test::Able::Object;

with( 'Test::Able::Method::Attribute' );

=head1 NAME

Test::Able

=head1 VERSION

0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

 package MyTest;

 use Moose;
 BEGIN { extends qw( Test::Able ); }
 use Test::More;

 sub foo: Test( 1 ) { ok( 1 ); }

 package main;

 my $t = MyTest->new;
 $t->meta->test_objects( $t );
 $t->meta->runtests;

(There are multiple ways, some terser & some more verbose, to accomplish the
above example.)

=head1 DESCRIPTION

An xUnit style testing framework inspired by Test::Class and built using
Moose.  It can do all the important things Test::Class can do and more.  The
prime advantages of using this module instead of Test::Class are flexibility
and power.  Namely, Moose.

This module was created for a couple of reasons:
 1.  To address perceived limitations in, and downfalls of, Test::Class.
 2.  To leverage existing Moose expertise for testing.
 3.  To bring Moose to the Perl testing game.

The core code and documentation are in L<Test::Able::Object>.

=head1 METHODS

=cut

sub import {
    for ( __PACKAGE__, Test::Able->meta->subclasses ) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class              => $_,
            metaclass_roles        => [ 'Test::Able::Object', ],
            method_metaclass_roles => [ 'Test::Able::Method', ],
        );
    }

    return;
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

=back

=cut

sub run_tests {
    my ( $proto, ) = @_;

    my $self = ref $proto ? $proto : $proto->new;
    $self->meta->current_test_object( $self, );
    $self->meta->run_tests;
    $self->meta->clear_current_test_object;

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
