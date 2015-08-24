package JSV::Keyword::Draft4::OneOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "oneOf" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $one_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    if (scalar(@$one_of) == 1) {
        my $sub_schema = $one_of->[0];
        local $context->{current_schema_pointer} =
            $context->{current_schema_pointer} . "/" . $class->keyword . "/0";
        $context->validate($sub_schema, $instance);
        return;
    }

    for (my $i = 0, my $l = scalar(@$one_of); $i < $l; $i++) {
        my $sub_schema = $one_of->[$i];
        local $context->{current_schema_pointer} =
            $context->{current_schema_pointer} . "/" . $class->keyword . "/" . $i;
        local $context->{errors} = [];
        $context->validate($sub_schema, $instance);
        $valid_cnt += 1 unless scalar @{ $context->{errors} };
    }

    unless ($valid_cnt == 1) {
        $context->log_error("The instance is not matched to one of schemas");
    }
}

1;
