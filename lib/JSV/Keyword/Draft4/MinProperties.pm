package JSV::Keyword::Draft4::MinProperties;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_OBJECT(); }
sub keyword { "minProperties" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "object";

    my $keyword_value = $class->keyword_value($schema);

    if (scalar keys %$instance >= $keyword_value) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance properties is less than minProperties value",
            $context,
        );
    }
}

1;
