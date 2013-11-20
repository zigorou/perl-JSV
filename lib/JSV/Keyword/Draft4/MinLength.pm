package JSV::Keyword::Draft4::MinLength;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_STRING(); }
sub keyword { "minLength" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "string";

    my $keyword_value = $class->keyword_value($schema);

    if (length($instance) >= $keyword_value) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance length is less than minLength value",
            $context,
        );
    }
}

1;
