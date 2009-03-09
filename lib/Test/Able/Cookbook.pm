package Test::Able::Cookbook;

=head1 NAME

Test::Able::Cookbook

=head1 Recipes

=head2 Basics

=over

=item Dumping execution plan

 $ENV{ 'TEST_VERBOSE' } = 1;
 $t->meta->dry_run( 1 );
 $t->run_tests;

Does everything but call the test (startup/setup/test/teardown/shutdown)
methods and validate method plans.  And part of "everything" is logging the
execution plan with $t->meta->log.

=back

=head2 Altering Method Lists

Its not recommended to do any of this while a test run is in progress.
The BUILD method in the test class is the best place.

=over

=item Remove superclass methods

 my $t_pkg = ref $t;
 for ( @{ $t->meta->method_types } ) {
     my $accessor = $_ . '_methods';
     $t->meta->$accessor( [ grep {
         $_->package_name eq $t_pkg;
     } @{ $t->meta->$accessor } ] );
 }

Unlike Test::Class its very easy to shed the methods from superclasses.

=item Explicit set

 my @methods = sort { $a->name cmp $b->name } $t->meta->get_all_methods;
 $t->meta->startup_methods(  [ @methods[ 17 .. 20 ] ] );
 $t->meta->setup_methods(    [ @methods[ 25 .. 28 ] ] );
 $t->meta->test_methods(     [ @methods[ 30,   32 ] ] );
 $t->meta->teardown_methods( [ @methods[ 13 .. 16 ] ] );
 $t->meta->shutdown_methods( [ @methods[ 21 .. 24 ] ] );

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
     [ grep { $_->name !~ /bar/; } @{ $t->meta->test_methods } ]
 );

=back

=head2 Test Planning

This functionality may not be working well, yet.  This is partly because
Test::Builder does not yet support deferred planning.  For now, to emulate
deferred planning, the plan should be set to no_plan up front.  Test::Able
will then persuade Test::Builder to print the plan at the end.

If this does not work, setting the plan to a numeric value will bypass
all of Test::Able's deferred planning support.

=over

=item Setting method plan during test run

 test plan => "no_plan", new_test_method => sub {
     $_[ 0 ]->meta->current_method->plan( 7 );
     ok( 1 ) for 1 .. 7;
 };

This will force the whole plan to be recalculated.

=back

=head2 Advanced

=over

=item Explicit setup & teardown for "Loop-Driven testing"

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

Since we're running the setup and teardown method lists explicitly in the loop
it would be nice to have the option of not running them implicitly (the normal
behavior - see L<Test::Able::Role::Meta::Class/run_methods> ).  Setting
do_setup the do_teardown above to false is an easy way to accomplish just
that.

=back

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
