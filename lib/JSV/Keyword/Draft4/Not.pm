package JSV::Keyword::Draft4::Not;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "not" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $not_schema = $class->keyword_value($schema);
    my $is_valid = 0;

    {
        local $context->{errors} = [];
        $context->validate($not_schema, $instance);
        $is_valid = 1 if scalar @{ $context->{errors} } == 0;
    }

    if ($is_valid) {
        $context->log_error("The instance is matched to schema of not keyword value");
    }
}

1;
