package Test::Able::Method;

use Moose::Role;

with qw( Test::Able::Planner );

=head1 NAME

Test::Able::Method

=head1 ATTRIBUTES

=over

=item type

Type of test method.  See L<Test::Able::Object/method_types> for the
list.

=cut

has 'type' => ( is => 'rw', isa => 'Str|Undef', );

=item do_setup

Only relevant for methods of type test.  Boolean indicating whether
to run the associated setup methods.

=cut

has 'do_setup' => ( is => 'rw', isa => 'Bool', lazy_build => 1, );

=item do_teardown

Only relevant for methods of type test.  Boolean indicating whether
to run the associated teardown methods.

=back

=cut

has 'do_teardown' => ( is => 'rw', isa => 'Bool', lazy_build => 1, );

sub _build_do_setup { return 1; }

sub _build_do_teardown { return 1; }

sub _build_plan { return 0; }

1;
