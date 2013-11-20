package JSV::Exception;

use strict;
use warnings;

use Carp;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/message pointer_tokens type keyword/]
);

sub throw {
    my ($class, $message, $context) = @_;
    my $exception = bless {
        message        => $message,
        pointer_tokens => $context->pointer_tokens,
        type           => $context->current_type,
        keyword        => $context->keyword,
    } => $class;
    croak $exception;
}

1;
