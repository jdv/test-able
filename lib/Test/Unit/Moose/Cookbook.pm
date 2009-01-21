package Test::Unit::Moose::Cookbook;

#TODO: turn all examples into tests

=head1 Recipes

=over

=item Dumping Test Execution Plan

 $t->meta->dry_run( 1 );
 $t->meta->run_tests;

This does everything but call the test (startup/setup/test/teardown/shutdown)
methods.

=item Modifying The Inheritted Test Execution Plan.

With Test::Class its impossible to inherit from a Test::Class based
module without running its test methods.  With Test::Unit::Moose we
can just alter the test method lists to our liking.  For example we
could dump all the test methods from our superclasses like so:

 my $t_pkg = ref $t;
 for ( @{ $t->meta->method_types } ) {
     my $accessor = $_ . '_methods';
     $t->meta->$accessor( [ grep {
         $_->package_name ne $t_pkg;
     } @{ $t->meta->$accessor } ]);
 }

=item explicitly building execution plan

Let's say we decide we want to manually setup our test method lists.

 my $t = BLA->new;
 $t->clear_all_methods;

 my @methods = $t->meta->get_all_methods;
 $t->meta->startup_methods(  [ @methods[ 0..2 ]   ] );
 $t->meta->setup_methods(    [ @methods[ 2..4]    ] );
 $t->meta->test_methods(     [ @methods[ 5..10 ]  ] );
 $t->meta->teardown_methods( [ $methods[ 12 ]     ] );
 $t->meta->shutdown_methods( [ @methods[ 22..23 ] ] );

=item explicit setup & teardown for "Loop-Driven testing"

Maybe you want to run the same test over a dataset without
writing seperate test methods.  Something like this should
work fine.

 sub test_on_x_and_y_and_z {
    my ( $self, ) = @_;

    @x = qw( 1 2 3 );
    @y = qw( a b c );
    @z = qw( foo bar baz );

    for my $x ( @x ) {
        for my $y ( @y ) {
            for my $z ( @z ) {
                $self->meta->run_setup_methods;
                $self->some_test_method( $x, $y, $z, );
                $self->meta->run_teardown_methods;
            }
        }
    }

    return;
 }

=item method order change

Let's say you wanted to see if your test object passes the ultimate
xUnit purity test:  random method call order.  No problem!  We'll
run the test object through its paces 10 times and re-order the
all the test methods on each run like so:

 use List::Util qw( shuffle );

 for ( 1 .. 10 ) {
    for ( @{ $t->meta->method_types } ) {
        my $accessor = $_ . '_methods';
        $t->meta->$accessor( [ shuffle @{ $t->meta->$accessor } ] );
    }
    $t->run_tests;
 }

=item test method filtering

    #by name
    $t->meta->test_methods(
        [ grep { $_->name =~ /bla/; } @{ $t->meta->test_methods } ]
    );

    # by source package
    my $t_pkg = ref $t;
    $t->meta->test_methods( [ grep {
        $_->package_name !~ /SomePackage/;
    } @{ $t->meta->test_methods } ]);

=back

=cut

1;
