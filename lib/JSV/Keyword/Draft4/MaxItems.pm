package JSV::Keyword::Draft4::MaxItems;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_ARRAY(); }
sub keyword { "maxItems" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "array";

    my $keyword_value = $class->keyword_value($schema);

    if (scalar(@$instance) <= $keyword_value) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance array length is greater than maxItems value",
            $context,
        );
    }
}

1;
