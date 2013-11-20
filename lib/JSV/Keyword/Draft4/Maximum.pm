package JSV::Keyword::Draft4::Maximum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Keyword qw(:constants);
use JSV::Exception;

sub instance_type { INSTANCE_TYPE_NUMERIC(); }
sub keyword { "maximum" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "number" || $context->current_type eq "integer";

    my $maximum           = $class->keyword_value($schema);
    my $exclusive_maximum = $class->keyword_value($schema, "exclusiveMaximum") || JSON::false;

    unless ($exclusive_maximum) {
        if ($instance <= $maximum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is greater than maximum keyword value",
                $context,
            );
        }
    }
    else {
        if ($instance < $maximum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is greater than or equals maximum keyword value",
                $context,
            );
        }
    }
}

1;
