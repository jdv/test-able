package Test::Unit::Moose;

use 5.008;
use Moose;
use Moose::Util::MetaRole;
use Test::Unit::Moose::Object;

with( 'Test::Unit::Moose::Method::Attribute' );

=head1 NAME

Test::Unit::Moose

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 package MyTest;

 use Moose;
 BEGIN { extends qw( Test::Unit::Moose ); }
 use Test::More;
 
 sub foo: Test( 1 ) { ok( 1 ); }
 
 package main;
 
 my $t = MyTest->new;
 $t->meta->test_objects( $t );
 $t->meta->runtests;

(There are multiple ways, some terser & some more verbose, to accomplish the
above example.)

=head1 DESCRIPTION

An xUnit style testing framework inspired by Test::Class and built using Moose.
It can do all the important things Test::Class can do and more.  The prime
advantages of using this module instead of Test::Class are flexibility and
power.  Namely, Moose.

This module was created for a couple of reasons:
 1.  To address perceived limitations in, and downfalls of, Test::Class.
 2.  To leverage existing Moose expertise for testing.
 3.  To bring Moose to the Perl testing game.

The core code and documentation are in L<Test::Unit::Moose::Object>.

=head1 METHODS 

=cut

sub import {
    for ( __PACKAGE__, Test::Unit::Moose->meta->subclasses ) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class              => $_,
            metaclass_roles        => [ 'Test::Unit::Moose::Object', ],
            method_metaclass_roles => [ 'Test::Unit::Moose::Method', ],
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

A convenience method around meta->run_tests().  Can be called as a class or
instance method.

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

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
