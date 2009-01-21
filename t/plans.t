#!/usr/bin/perl

use lib 't/lib';

use Bar;
use strict;
use Test::Able;
use Test::More 'no_plan';
use warnings;

# This whole test script is also a test for Test::Builder "integration".

my @methods_no_plan = qw(
    startup_bar2
    startup_bar4
    setup_bar1
    setup_bar3
    test_4
    test_bar2
    test_bar4
    teardown_0
    teardown_bar2
    shutdown
    shutdown_bar3
);

# Method plan defaults.
{
    my $t = Bar->new;
    is(
        $t->meta->get_method( 'startup_bar2' )->plan, 0,
        'aux methods default to 0'
    );
    is(
        $t->meta->get_method( 'test_bar2' )->plan, 'no_plan',
        'test type methods default to no_plan'
    );
    print STDERR $t->meta->get_method( 'test_bar2' )->plan;
    Class::MOP::remove_metaclass_by_name( 'Bar' );
}

# Object has no_plan if any method has no_plan.
if(10){
    my $t = Bar->new;
    $t->meta->test_objects( [ $t, ] );
    ok( $t->meta->plan eq 'no_plan', 'obj no_plan if any meth no_plan' );
    Class::MOP::remove_metaclass_by_name( 'Bar' );
}

# Object has plan up front if all methods do.
if(10){
    my $t = Bar->new;
    $t->meta->test_objects( [ $t, ] );
    set_plan_on_no_plan_methods( $t, @methods_no_plan, );
    ok( $t->meta->plan == 114, 'obj has plan before run' );
    Class::MOP::remove_metaclass_by_name( 'Bar' );
}

# Object can have deferred plan
# which implies that object plan changes
# on any method plan change.
if(10){
    my $t = Bar->new;
    ok( $t->meta->plan eq 'no_plan', 'obj has no_plan before' );
    set_plan_on_no_plan_methods( $t, @methods_no_plan, );
    ok( $t->meta->plan == 114, 'obj has plan after' );
    Class::MOP::remove_metaclass_by_name( 'Bar' );
}

# object plan changes when any of the method lists change.
if(10){
    my $t = Bar->new;
    set_plan_on_no_plan_methods( $t, @methods_no_plan, );
    ok( $t->meta->plan == 114, 'obj has plan' );
    $t->meta->setup_methods( [] );
    ok( $t->meta->plan == 58, 'obj plan changes after method list change' );
    $t->run_tests;
    # TODO: this is lame; find a real way to do this.
    $t->meta->last_master_plan( $t->meta->last_master_plan - 8 );
    $t->meta->clear_plan;
    $t->meta->master_plan;
    Class::MOP::remove_metaclass_by_name( 'Bar' );
}

sub set_plan_on_no_plan_methods {
    my ( $t, @methods_no_plan, ) = @_;
    
    for ( @{ $t->meta->method_types } ) {
        my $accessor = $_ . '_methods';
        for my $method ( @{ $t->meta->$accessor } ) {
            if ( grep { $method->name eq $_; } @methods_no_plan ) {
                if ( $method->name eq 'test_4' ) {
                    $method->plan( 4 );
                }
                else {
                    $method->plan( 0 );
                }
            }
        }
    }

    return;
}

sub END {
    my $tb = Test::Builder->new;
    die 'bad plan (' . $tb->expected_tests . ')'
      unless $tb->expected_tests == 66;
}
