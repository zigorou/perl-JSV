package JSV::Exception;

use strict;
use warnings;

use Carp;
use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/error errors history/]
);

sub throw {
    my ($class, %args) = @_;
    croak $class->new(%args);
}

sub get_error {
    my ($self, $pointer) = @_;

    if ( $self->error ) {
        return $self->error;
    }
    elsif ( $self->errors ) {
        if ( $pointer ) {
            return grep { $_->{pointer} eq $pointer } @{ $self->errors };
        }
        else {
            return $self->errors;
        }
    }
}

sub get_error_map {
    my $self = shift;
    return +{map { $_->{pointer} => $_ } @{ $self->errors }};
}

1;
