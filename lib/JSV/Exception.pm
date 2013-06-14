package JSV::Exception;

use strict;
use warnings;

use Carp;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/message pointer_tokens type keyword/]
);

sub throw {
    my ($class, $message, $opts) = @_;
    my $exception = bless {
        message => $message,
        %$opts,
    } => $class;
    croak $exception;
}

1;
