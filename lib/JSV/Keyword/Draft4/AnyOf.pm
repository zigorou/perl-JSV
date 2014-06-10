package JSV::Keyword::Draft4::AnyOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "anyOf" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $any_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$any_of) {
        local $context->{errors} = [];
        $context->validate($sub_schema, $instance);
        $valid_cnt += 1 unless scalar @{ $context->{errors} };
    }

    if ($valid_cnt == 0) {
        $context->log_error("The instance is not valid to any of schemas");
    }
}

1;
