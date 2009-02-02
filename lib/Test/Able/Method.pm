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

has 'type' => ( is => 'rw', isa => 'Str|Undef', lazy_build => 1, );

=item do_setup

Only relevant for methods of type test.  Boolean indicating whether
to run the associated setup methods.

=cut

has 'do_setup' => ( is => 'rw', isa => 'Bool', lazy_build => 1, );

=item do_teardown

Only relevant for methods of type test.  Boolean indicating whether
to run the associated teardown methods.

=cut

has 'do_teardown' => ( is => 'rw', isa => 'Bool', lazy_build => 1, );

=item plan_builders

List of names of methods used to determine the method's plan.

=cut

has 'plan_builders' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1, );

=item type_builders

List of names of methods used to determine the method's type.

=back

=cut

has 'type_builders' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1, );

sub _build_do_setup { 1; }

sub _build_do_teardown { 1; }

sub _build_plan_builders {
    my ( $self, ) = @_;

    return [ qw( plan_from_attribute plan_from_sub_name ) ];
}

sub _build_type_builders {
    my ( $self, ) = @_;

    return [ qw( type_from_attribute type_from_sub_name ) ];
}

sub _build_plan {
    my ( $self, ) = @_;

    my $plan;
    for ( @{ $self->plan_builders } ) {
        last if $plan = $self->$_;
    }
    $plan ||= 0;

    return $plan;
}

=head1 METHODS

=over

=item plan_from_attribute

Return the method's test plan as determined via a subroutine
attribute if possible.

=cut

sub plan_from_attribute {
    my ( $self, ) = @_;

    my $attr = $self->fetch_sub_attribute;

    return $1 if $attr && $attr =~ /\(\s*(no_plan|\d+)\s*\)/;

    return;
}

=item plan_from_sub_name

Return the method's test plan as determined via the subroutine's
name if possible.

=cut

sub plan_from_sub_name {
    my ( $self, ) = @_;

    for ( @{ $self->associated_metaclass->method_types } ) {
        return $1 if $self->name =~ /^${_}_?(\d+)_/;
    }

    return;
}

sub _build_type {
    my ( $self, ) = @_;

    my $type;
    for ( @{ $self->type_builders } ) {
        last if $type = $self->$_;
    }

    return $type;
}

=item type_from_attribute

Return the method's type as determined via a subroutine
attribute if possible.

=cut

sub type_from_attribute {
    my ( $self, ) = @_;

    my $attr = $self->fetch_sub_attribute;
    return unless $attr;

    for ( @{ $self->associated_metaclass->method_types } ) {
        my $type = ucfirst $_;
        return $_ if $attr =~ /^$type/;
    }

    return;
}

=item type_from_sub_name

Return the method's type as determined via the subroutine's
name if possible.

=cut

sub type_from_sub_name {
    my ( $self, ) = @_;

    for ( @{ $self->associated_metaclass->method_types } ) {
        return $_ if $self->name =~ /^${_}_/;
    }

    return;
}

=item fetch_sub_attribute

Return the subroutine attribute if one exists.

=back

=cut

sub fetch_sub_attribute {
    my ( $self, ) = @_;

    my $attrs = Test::Able::Method::Attribute->__sub_attributes;
    my $attrs_pkg = $attrs->{ $self->package_name };
    my ( $attr ) = grep { $_->[ 0 ] eq $self->name } @{ $attrs_pkg };

    return $attr->[ 1 ];
}

1;
