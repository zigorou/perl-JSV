package JSV::Keyword::Draft4::Maximum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_NUMERIC(); }
sub keyword() { "maximum" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $maximum           = $class->keyword_value($schema);
    my $exclusive_maximum = $class->keyword_value($schema, "exclusiveMaximum") || JSON::false;

    if ($exclusive_maximum) {
        if ($instance >= $maximum) {
            $context->log_error("The instance value is greater than or equals maximum keyword value");
        }
    }
    else {
        if ($instance > $maximum) {
            $context->log_error("The instance value is greater than maximum keyword value");
        }
    }
}

1;
