package Test::Able::Helpers;

use List::Util qw( shuffle );
use Sub::Exporter -setup => {
    exports => [ qw(
        prune_super_methods
        shuffle_methods
        get_loop_plan
    ), ],
    groups => {
        default => [ qw(
            prune_super_methods
            shuffle_methods
            get_loop_plan
        ), ],
    },
};

=head1 NAME

Test::Able::Helpers

=head1 SYNOPSIS

 use Test::Able::Helpers;

 my $t = MyTest;
 $t->shuffle_methods;
 $t->run_tests;

=head1 DESCRIPTION

Test::Able::Helpers are a collection of mixin methods that can
be exported into the calling test class.  These are meant to
make doing some things with Test::Able easier.

=head1 METHODS

=over

=item prune_super_methods

=cut

sub prune_super_methods {
    my ( $self, @types, ) = @_;

    @types = @{ $self->meta->method_types } unless @types;

    my $self_pkg = ref $self;
    for ( @types ) {
        my $accessor = $_ . '_methods';
        $self->meta->$accessor( [ grep {
            $_->package_name eq $self_pkg;
        } @{ $self->meta->$accessor } ] );
    }

    return;
}

=item shuffle_methods

=cut

sub shuffle_methods {
    my ( $self, @types, ) = @_;

    @types = @{ $self->meta->method_types } unless @types;

    for ( @types ) {
        my $accessor = $_ . '_methods';
        $self->meta->$accessor( [ shuffle @{ $self->meta->$accessor } ] );
    }

    return;
}

=item get_loop_plan

=back

=cut

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

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
