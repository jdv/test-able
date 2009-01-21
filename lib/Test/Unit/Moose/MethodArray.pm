package Test::Unit::Moose::MethodArray;

use Moose;
use Tie::Array;

extends qw( Tie::StdArray );

sub STORE {
    my $self = shift;

    my @ret = $self->SUPER::STORE( @_ );
    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return @ret;
}

sub STORESIZE {
    my $self = shift;

    my @ret = $self->SUPER::STORESIZE( @_ );
    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return @ret;
}

sub DELETE {
    my $self = shift;

    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return $self->SUPER::DELETE( @_ );
}

sub CLEAR {
    my $self = shift;

    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return $self->SUPER::CLEAR( @_ );
}

sub DESTROY {
    my $self = shift;

    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return $self->SUPER::DESTROY( @_ );
}

sub PUSH {
    my $self = shift;

    $_[ 0 ]->associated_metaclass->clear_plan
      if defined $_[ 0 ] && $_[ 0 ]->can( 'associated_metaclass' );
    return $self->SUPER::PUSH( @_ );
}

sub POP {
    my $self = shift;

    my @ret = $self->SUPER::POP( @_ );
    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return @ret;
}

sub SHIFT {
    my $self = shift;

    my @ret = $self->SUPER::SHIFT( @_ );
    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return @ret;
}

sub UNSHIFT {
    my $self = shift;

    $_[ 0 ]->associated_metaclass->clear_plan
      if defined $_[ 0 ] && $_[ 0 ]->can( 'associated_metaclass' );
    return $self->SUPER::UNSHIFT( @_ );
}

sub SPLICE {
    my $self = shift;

    my @ret = $self->SUPER::SPLICE( @_ );
    $self->[ 0 ]->associated_metaclass->clear_plan
      if defined $self->[ 0 ] && $self->[ 0 ]->can( 'associated_metaclass' );
    return @ret;
}

1;
