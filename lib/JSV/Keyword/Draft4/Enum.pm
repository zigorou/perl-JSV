package JSV::Keyword::Draft4::Enum;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSON;
use List::MoreUtils qw(firstidx);

use JSV::Util::Compare qw(deep_eq);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "enum" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $enum = $class->keyword_value($schema);
    for (@$enum) {
        return 1 if deep_eq($instance, $_, $context->{loose_type});
    }

    $context->log_error("The instance value does not be included in the enum list");
}

1;
