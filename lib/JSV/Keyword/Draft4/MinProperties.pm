package JSV::Keyword::Draft4::MinProperties;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { "minProperties" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $keyword_value = $class->keyword_value($schema);

    if (scalar keys %$instance < $keyword_value) {
        $context->log_error("The instance properties is less than minProperties value");
    }
}

1;
