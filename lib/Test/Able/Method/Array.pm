package Test::Able::Method::Array;

=head1 NAME

Test::Able::Method::Array

=cut

use overload '%{}' => sub {
    my %methods;
    @methods{ map { $_->name; } @{ $_[ 0 ] } } = @{ $_[ 0 ] };
    return \%methods;
};

1;
