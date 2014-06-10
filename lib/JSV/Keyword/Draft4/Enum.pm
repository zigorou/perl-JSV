package JSV::Keyword::Draft4::Enum;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSON;
use List::MoreUtils qw(firstidx);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "enum" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $enum = $class->keyword_value($schema);
    my $instance_as_json = $context->json->encode($instance);
    my $matched_idx = firstidx { $instance_as_json eq $context->json->encode($_); } @$enum;

    if ($matched_idx == -1) {
        $context->log_error("The instance value does not be included in the enum list");
    }
}

1;
