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

    if (scalar(@$any_of) == 1) {
        my $sub_schema = $any_of->[0];
        local $context->{current_schema_pointer} =
            $context->{current_schema_pointer} . "/" . $class->keyword . "/0";
        $context->validate($sub_schema, $instance);
        return;
    }

    for (my $i = 0, my $l = scalar(@$any_of); $i < $l; $i++) {
        my $sub_schema = $any_of->[$i];
        local $context->{current_schema_pointer} =
            $context->{current_schema_pointer} . "/" . $class->keyword . "/" . $i;
        local $context->{errors} = [];
        $context->validate($sub_schema, $instance);
        $valid_cnt += 1 unless scalar @{ $context->{errors} };
    }

    if ($valid_cnt == 0) {
        $context->log_error("The instance is not valid to any of schemas");
    }
}

1;
