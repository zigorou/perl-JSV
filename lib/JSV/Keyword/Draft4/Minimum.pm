package JSV::Keyword::Draft4::Minimum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_NUMERIC(); }
sub keyword { "minimum" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "number" || $context->current_type eq "integer";

    my $minimum           = $class->keyword_value($schema);
    my $exclusive_minimum = $class->keyword_value($schema, "exclusiveMinimum") || JSON::false;

    unless ($exclusive_minimum) {
        if ($instance >= $minimum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is less than minimum keyword value",
                $context,
            );
        }
    }
    else {
        if ($instance > $minimum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is less than or equals minimum keyword value",
                $context,
            );
        }
    }
}

1;
