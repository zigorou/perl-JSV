package JSV::Keyword::Draft4::Minimum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_NUMERIC(); }
sub keyword() { "minimum" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $minimum           = $class->keyword_value($schema);
    my $exclusive_minimum = $class->keyword_value($schema, "exclusiveMinimum") || JSON::false;

    if ($exclusive_minimum) {
        if ($instance <= $minimum) {
            $context->log_error("The instance value is less than or equals minimum keyword value");
        }
    }
    else {
        if ($instance < $minimum) {
            $context->log_error("The instance value is less than minimum keyword value");
        }
    }
}

1;
