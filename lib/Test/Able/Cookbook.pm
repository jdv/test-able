package Test::Able::Cookbook;

#TODO: Turn all recipes into tests.

=head1 Recipes

=head2 Basics

=over

=item Dumping execution plan

 $t->meta->dry_run( 1 );
 $t->meta->run_tests;

Does everything but call the test (startup/setup/test/teardown/shutdown)
methods.  And part of "everything" is logging the execution plan with
$t->meta->log.

=item Define and Run in same file

package MyTests;

use Moose;
BEGIN { extend 'Test::Able'; }

sub test {}

...

MyTests->import;
MyTests->run_tests;

Normally a test class will be defined in one file and run in another.  But
sometimes its nice to do it all in one place.  The only non-obvious part is
that Test::Able's import method must be run.

=back

=head2 Altering Method Lists

Its not recommended to do any of this while a test run is in progress.
The BUILD method in the test class could work.

=over

=item Remove superclass methods

 my $t_pkg = ref $t;
 for ( @{ $t->meta->method_types } ) {
     my $accessor = $_ . '_methods';
     $t->meta->$accessor( [ grep {
         $_->package_name ne $t_pkg;
     } @{ $t->meta->$accessor } ] );
 }

Unlike Test::Class its very easy to shed the methods from superclasses.

=item Explicit set

 my @methods = $t->meta->get_all_methods;
 $t->meta->startup_methods(  [ @methods[ 0..2 ]   ] );
 $t->meta->setup_methods(    [ @methods[ 2..4]    ] );
 $t->meta->test_methods(     [ @methods[ 5..10 ]  ] );
 $t->meta->teardown_methods( [ $methods[ 12 ]     ] );
 $t->meta->shutdown_methods( [ @methods[ 22..23 ] ] );

=item Ordering

 use List::Util qw( shuffle );
 for ( 1 .. 10 ) {
     for ( @{ $t->meta->method_types } ) {
         my $accessor = $_ . '_methods';
         $t->meta->$accessor( [ shuffle @{ $t->meta->$accessor } ] );
     }
    $t->run_tests;
 }

Simple xUnit purity test.

=item Filtering

 $t->meta->test_methods(
     [ grep { $_->name =~ /bla/; } @{ $t->meta->test_methods } ]
 );

=back

=head2 Test Planning

This functionality is not working well, yet.  This is partly because
Test::Builder does not yet support deferred planning.  For now, to emulate
deferred planning, the plan should be set to no_plan up front.  Test::Able
will then persuade Test::Builder to print the plan at the end.

=over

=item Setting method plan during test run

 sub test_method {
     ...
     $self->current_test_method->plan( $new_plan );
     ...
 }

This will force the whole plan to be recalculated.

=back

=head2 Advanced

=over

=item Explicit setup & teardown for "Loop-Driven testing"

 sub BUILD {
     my ( $self, ) = @_;

    my $m = $t->meta->test_methods->{ 'test_on_x_and_y_and_z' };
    $m->do_setup( 0 );
    $m->do_teardown( 0 );

    return;
 }

 sub test_on_x_and_y_and_z {
     my ( $self, ) = @_;

     @x = qw( 1 2 3 );
     @y = qw( a b c );
     @z = qw( foo bar baz );

     my $plan = @x * @y * @x;
     $plan += @{ $self->meta->setup_methods } * $plan
       + @{ $self->meta->teardown_methods } * $plan;
     $self->current_test_method->plan( $plan );

     for my $x ( @x ) {
         for my $y ( @y ) {
             for my $z ( @z ) {
                 $self->meta->run_methods( 'setup' );
                 $self->{ 'args' } = { x => $x, y=> $y, z => $z, };
                 $self->some_test_method;
                 $self->meta->run_methods( 'teardown' );
             }
         }
     }

     return;
 }

Since we're running the setup and teardown method lists explicitly in the loop
it would be nice to have the option of not running them implicitly (the normal
behavior - see L<Test::Able::Object/run_methods> ).  Setting do_setup the
do_teardown above to false is an easy way to accomplish just that.  Notice, as
illustrated in this recipe, that the method lists can be accessed as a
HashRef.

=back

=cut

1;
