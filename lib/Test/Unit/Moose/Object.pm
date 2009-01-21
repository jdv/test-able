package Test::Unit::Moose::Object;

use Moose::Role;
use Test::Unit::Moose::Method;
use Test::Unit::Moose::MethodArray;

with qw( Test::Unit::Moose::Planner );

=item method_types

=cut

has 'method_types' => (
    is => 'ro', isa => 'ArrayRef',
    default => sub { [ qw( startup setup test teardown shutdown ) ] },
);

=item startup_methods

=cut

has 'startup_methods' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;

        tie( my @array, 'Test::Unit::Moose::MethodArray' );
        push( @array, @{ $value }, );
        $self->clear_plan;

        return;
    },
);

=item setup_methods

=cut

has 'setup_methods' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;

        tie( my @array, 'Test::Unit::Moose::MethodArray' );
        push( @array, @{ $value }, );
        $self->clear_plan;

        return;
    },
);

=item test_methods

=cut

has 'test_methods' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;

        tie( my @array, 'Test::Unit::Moose::MethodArray' );
        push( @array, @{ $value }, );
        $self->clear_plan;

        return;
    },
);

=item teardown_methods

=cut

has 'teardown_methods' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;

        tie( my @array, 'Test::Unit::Moose::MethodArray' );
        push( @array, @{ $value }, );
        $self->clear_plan;

        return;
    },
);

=item shutdown_methods

=cut

has 'shutdown_methods' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;

        tie( my @array, 'Test::Unit::Moose::MethodArray' );
        push( @array, @{ $value }, );
        $self->clear_plan;

        return;
    },
);

=item test_objects

=cut

has 'test_objects' => (
    is => 'rw', isa => 'ArrayRef', lazy_build => 1,
    trigger => sub {
        my ( $self, $value, ) = @_;
        for( @{ $value } ) {
            $_->meta->test_runner_object( $self, );
        }
    },
);

=item current_test_object

=cut

has 'current_test_object' => (
    is => 'rw', isa => 'Object', clearer => 'clear_current_test_object',
);

=item current_test_method

=cut

has 'current_test_method' => (
    is => 'rw', isa => 'Object', clearer => 'clear_current_test_method',
);

=item test_runner_object

=cut

has 'test_runner_object' => (
    is => 'rw', isa => 'Object',
);

=item dry_run

=cut

has 'dry_run' => (
    is => 'rw', isa => 'Bool', default => 0,
);

sub _build_test_objects {
    my ( $self, ) = @_;

    if ( $self->current_test_object ) {
        $self->current_test_object->meta->test_runner_object( $self, );
        return [ $self->current_test_object, ];
    }
    else { return []; }
}

=item run_tests

=cut

sub run_tests {
    my ( $self, ) = @_;

    $self->test_runner_object( $self, );
    for ( @{ $self->test_objects } ) {
        $_->meta->test_runner_object( $self, );
    }

    # Initiate plan management.
    $self->master_plan;

    for ( @{ $self->test_objects } ) {
        $_->meta->current_test_object( $_ );

        $_->meta->run_startup_methods;
        $_->meta->run_test_methods;
        $_->meta->run_shutdown_methods;

        $_->meta->clear_current_test_object;
    }

    return;
}

=item run_test_methods

=cut

sub run_test_methods {
    my ( $self, ) = @_;

    my $methods = $self->test_methods;
    my $count   = @{ $methods };
    my $i;
    for ( @{ $methods } ) { 
        $self->current_test_method( $_ );

        $self->run_setup_methods;

        $self->log(
            $self->current_test_object . '->' . $_->name
              . "(test/" . $_->plan . ")"
              . '('. ++$i . "/$count)"
        );

        my $method_name = $_->name;
        unless ( $self->dry_run ) {
            $self->current_test_object->$method_name;
        }

        $self->run_teardown_methods;

        $self->clear_current_test_method;
    }

    return;
}

=item run_startup_methods

=cut

sub run_startup_methods {
    my ( $self, ) = @_;

    return $self->_run_auxiliary_methods( 'startup' );
}

=item run_shutdown_methods

=cut

sub run_shutdown_methods {
    my ( $self, ) = @_;

    return $self->_run_auxiliary_methods( 'shutdown' );
}

=item run_setup_methods

=cut 
sub run_setup_methods {
    my ( $self, ) = @_;

    return $self->_run_auxiliary_methods( 'setup' );
}

=item run_teardown_methods

=cut

sub run_teardown_methods {
    my ( $self, ) = @_;

    return $self->_run_auxiliary_methods( 'teardown' );
}

sub _run_auxiliary_methods {
    my ( $self, $type, ) = @_;
    my $accessor_name    = $type . '_methods';

    die "current_test_object required to run $type method list"
      unless defined $self->current_test_object;

    my $methods = $self->$accessor_name;
    my $count   = @{ $methods };
    my $i;
    for ( @{ $methods } ) { 
        my $method_name = $_->name;
        $self->log(
            $self->current_test_object . '->' . $method_name
              . "($type/" . $_->plan . ")"
              . '('. ++$i . "/$count)"
        );

        unless ( $self->dry_run ) {
            $self->current_test_object->$method_name;
        }
    }

    return;
}

=item clear_all_methods

=cut

sub clear_all_methods {
    my ( $self, ) = @_;

    for ( @{ $self->method_types } ) {
        my $clear_name = 'clear_' . $_ . '_methods';
        my $has_name   = 'has_' . $_ . '_methods';
        $self->$clear_name if $self->$has_name;
    }

    return;
}

=item build_all_methods

=cut

sub build_all_methods {
    my ( $self, ) = @_;

    for ( @{ $self->method_types } ) {
        my $accessor_name = $_ . '_methods';
        my $has_name      = 'has_' . $_ . '_methods';
        $self->$accessor_name unless $self->$has_name;
    }

    return;
}

sub _build_startup_methods {
    my ( $self, ) = @_;

    return $self->_build_methods_of_type( 'startup' );
}

sub _build_setup_methods {
    my ( $self, ) = @_;

    return $self->_build_methods_of_type( 'setup' );
}

sub _build_test_methods {
    my ( $self, ) = @_;

    return $self->_build_methods_of_type( 'test' );
}

sub _build_teardown_methods {
    my ( $self, ) = @_;

    return $self->_build_methods_of_type( 'teardown' );
}

sub _build_shutdown_methods {
    my ( $self, ) = @_;

    return $self->_build_methods_of_type( 'shutdown' );
}

sub _build_methods_of_type {
    my ( $self, $type, ) = @_;

    die "current_test_object required to build $type method list"
      unless defined $self->current_test_object;

    my @methods;
    tie( @methods, 'Test::Unit::Moose::MethodArray' );
    for ( $self->current_test_object->meta->get_all_methods ) {
        if ( $_->can( 'type' ) ) {
            my $method_type = $_->type;
            push( @methods, $_ )
              if defined $method_type && $method_type eq $type;
        }
    }

    return [ sort { $a->name cmp $b->name } @methods ];
}

=item log

=cut

sub log {
    my $self = shift;

    $self->builder->diag( @_ );

    return;
}

sub _build_plan {
    my ( $self, ) = @_;

    my $plan;
    my $test_method_count = @{ $self->test_methods };
    METHOD_TYPE: for ( @{ $self->method_types } ) {
        my $accessor_name = $_ . '_methods';
        for ( @{ $self->$accessor_name } ) {
                if ( $_->plan eq 'no_plan' ) {
                    $plan = $_->plan;
                    last METHOD_TYPE;
                }
                else {
                if ( $accessor_name =~ /^setup|teardown/ ) {
                        $plan += $_->plan * $test_method_count;
                }
                else {
                        $plan += $_->plan;
                }
                }
        }
    }
    $plan ||= 'no_plan';

    return $plan;
}

=item clear_plan

Special purpose plan clearer that dumps plan and master_plan.

=cut

#TODO: Could change this if Class::MOP bug 41449 is resolved.
#sub clear_plan {
before 'clear_plan' => sub {
    my ( $self, ) = @_;

    delete $self->{ 'plan' };
    delete $self->{ 'master_plan' };

    return;
};
#}

# Hack Test::Builder cause it doesn't do deferred plans; yet.
sub _build_master_plan {
    my ( $self, ) = @_;

    $self->_hack_test_builder( $self->builder );

    my $plan;
    for ( @{ $self->test_objects } ) {
        $_->meta->current_test_object( $_ );

        my $object_plan = $_->meta->plan;
        if ( $object_plan eq 'no_plan' ) {
            $plan = $object_plan;
            last;
        }
        else { $plan += $object_plan; }

        $_->meta->clear_current_test_object;
    }
    $plan ||= 'no_plan';

    if ( $self->builder->{No_Plan} || $self->builder->{was_No_Plan} ) {
        if ( $self->has_last_master_plan && $self->last_master_plan ne $plan ) {
            my $last = $self->last_master_plan;
            my $plan_diff
              = ( $plan eq 'no_plan' ? 0 : $plan )
              - ( $last eq 'no_plan' ? 0 : $last );
            $self->builder->{No_Plan}     = 0;
            $self->builder->{was_No_Plan} = 1;
            $self->builder->{Expected_Tests} += $plan_diff;
        }
        else {
            if ( $plan =~ /^\d+$/ ) {
                $self->builder->{Expected_Tests} = $plan;
            }
            else { $self->builder->{No_Plan} = 1; }
        }
    }

    $self->last_master_plan( $plan );
    return $plan;
}

# Hack Test::Builder cause it doesn't do deferred plans; yet.
my $hacked_test_builder;
sub _hack_test_builder {
    my ( $self, ) = @_;

    return if $hacked_test_builder;
    $hacked_test_builder++;

    no warnings 'redefine';
    my $original_sub = \&Test::Builder::_ending;
    *Test::Builder::_ending = sub {
        my $self_builder = shift;
        if ( $self->master_plan =~ /\d+/ ) {
            $self_builder->expected_tests( $self->builder->{Expected_Tests} );
            $self_builder->no_header( 1 );
        }
        return $self_builder->$original_sub( @_, );
    };
}

=head1 AUTHOR 

Justin DeVuyst E<lt>justin@devuyst.comE<gt>

=head1 COPYRIGHT

Copyright 2008 by Justin DeVuyst.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

1;
