package Test::Able::Planner;

use Moose::Role;
use Moose::Util::TypeConstraints;
require Test::Builder;

=item builder

The Test::Builder instance.

=cut

has 'builder' => (
    is => 'ro', isa => 'Test::Builder', lazy_build => 1,
);

subtype 'Plan' => as 'Str' => where { /^no_plan|\d+$/; };

=item plan

Test plan similar to Test::Builder's.

=cut

has 'plan' => (
    is => 'rw', isa => 'Plan', lazy_build => 1,
    trigger => sub {
        my ( $self, ) = @_;

        if ( $self->isa( 'Moose::Meta::Method' ) ) {
            $self->associated_metaclass->clear_plan;
        }

        return;
    },
);

=item master_plan

=cut

has 'master_plan' => (
    is => 'rw', isa => 'Plan', lazy_build => 1,
);

=item last_master_plan

=cut

has 'last_master_plan' => (
    is => 'rw', isa => 'Plan', predicate => 'has_last_master_plan',
);

sub _build_builder {
    my ( $self, ) = @_;

    return Test::Builder->new;
}

1;
