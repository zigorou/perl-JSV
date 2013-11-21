package JSV::Keyword::Draft4::MultipleOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_NUMERIC(); }
sub keyword { "multipleOf" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $keyword_value = $class->keyword_value($schema);
    my $result = $instance / $keyword_value;

    if ($result - int($result) != 0) {
        $context->log_error("The instance doesn't multiple of schema value");
    }
}

1;
