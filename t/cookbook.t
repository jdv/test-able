#!/usr/bin/perl

use lib 't/lib';

use Bar ();
use Foo ();
use strict;
use Test::More 'no_plan';
use warnings;

# Correcting plan that's wrong (on purpose for other tests).
Bar->meta->get_method( 'test_4' )->plan( 4 );

# Ensuring things goes exactly as planned.
Bar->meta->on_method_plan_fail( 'die' );
Foo->meta->on_method_plan_fail( 'die' );

# Dumping execution plan
{
    local $ENV{ 'TEST_VERBOSE' } = 1;
    my $t = Bar->new;
    $t->meta->dry_run( 1 );
    $t->run_tests;
    $t->meta->dry_run( 0 );
    is( $t->meta->builder->current_test, 0, 'no tests ran' );
}

# Remove superclass methods
{
    my $t = Foo->new;
    # Setting to -1 to account for the is() at the end of the "Dumping
    # execution plan" code that is outside of the Test::Able Classes.
    $t->meta->last_runner_plan( -1 );
    my $t_pkg = ref $t;
    for ( @{ $t->meta->method_types } ) {
        my $accessor = $_ . '_methods';
        $t->meta->$accessor( [ grep {
            $_->package_name eq $t_pkg;
        } @{ $t->meta->$accessor } ] );
    }
    $t->run_tests;
}

# Explicit set
{
    my $t = Bar->new;
    my @methods = sort { $a->name cmp $b->name } $t->meta->get_all_methods;
    $t->meta->startup_methods(  [ @methods[ 17 .. 20 ] ] );
    $t->meta->setup_methods(    [ @methods[ 25 .. 28 ] ] );
    $t->meta->test_methods(     [ @methods[ 30,   32 ] ] );
    $t->meta->teardown_methods( [ @methods[ 13 .. 16 ] ] );
    $t->meta->shutdown_methods( [ @methods[ 21 .. 24 ] ] );
    $t->run_tests;
    # Dumping the unusual method lists.
    $t->meta->clear_all_methods;
}

# Ordering
{
    my $t = Bar->new;
    use List::Util qw( shuffle );
    for ( 1 .. 10 ) {
        for ( @{ $t->meta->method_types } ) {
            my $accessor = $_ . '_methods';
            $t->meta->$accessor( [ shuffle @{ $t->meta->$accessor } ] );
        }
        $t->run_tests;
    }
}

# Filtering
{
    my $t = Bar->new;
    $t->meta->test_methods(
        [ grep { $_->name !~ /bar/; } @{ $t->meta->test_methods } ]
    );
    $t->run_tests;
    # Dumping the altered test method list.
    $t->meta->clear_test_methods;
}

# Setting method plan during test run
{
    eval '
        package Bar;
        test plan => "no_plan", new_test_method => sub {
            $_[ 0 ]->meta->current_method->plan( 7 );
            ok( 1 ) for 1 .. 7;
        };
    ';
    my $t = Bar->new;
    $t->run_tests;
}

# Explicit setup & teardown for "Loop-Driven testing"
{
    eval q[
        package Bar;

        test do_setup => 0, do_teardown => 0, test_on_x_and_y_and_z => sub {
            my ( $self, ) = @_;

            my @x = qw( 1 2 3 );
            my @y = qw( a b c );
            my @z = qw( foo bar baz );

            $self->meta->current_method->plan(
                $self->get_loop_plan( 'test_bar1', @x * @y * @x, ),
            );

            for my $x ( @x ) {
                for my $y ( @y ) {
                    for my $z ( @z ) {
                        $self->meta->run_methods( 'setup' );
                        $self->{ 'args' } = { x => $x, y => $y, z => $z, };
                        $self->test_bar1;
                        $self->meta->run_methods( 'teardown' );
                    }
                }
            }

            return;
        };

        sub get_loop_plan {
            my ( $self, $test_method_name, $test_count, ) = @_;

            my $test_plan
              = $self->meta->test_methods->{ $test_method_name }->plan;
            return 'no_plan' if $test_plan eq 'no_plan';

            my $setup_plan;
            for ( @{ $self->meta->setup_methods } ) {
                return 'no_plan' if $_->plan eq 'no_plan';
                $setup_plan += $_->plan;
            }

            my $teardown_plan;
            for ( @{ $self->meta->teardown_methods } ) {
                return 'no_plan' if $_->plan eq 'no_plan';
                $teardown_plan += $_->plan;
            }

            return(
                ( $test_plan + $setup_plan + $teardown_plan ) * $test_count
            );
        }
    ];

    # Dumping the test methods list so the new method gets picked up on build.
    Bar->meta->clear_test_methods;
    my $t = Bar->new;
    $t->run_tests;
}
