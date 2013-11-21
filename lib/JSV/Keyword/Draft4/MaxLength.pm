package JSV::Keyword::Draft4::MaxLength;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_STRING(); }
sub keyword { "maxLength" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $keyword_value = $class->keyword_value($schema);

    if (length($instance) > $keyword_value) {
        $context->log_error("The instance length is greater than maxLength value");
    }
}

1;
