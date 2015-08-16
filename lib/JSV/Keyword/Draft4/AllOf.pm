package JSV::Keyword::Draft4::AllOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "allOf" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $all_of = $class->keyword_value($schema);

    for (my $i = 0, my $l = scalar(@$all_of); $i < $l; $i++) {
        my $sub_schema = $all_of->[$i];
        local $context->{current_schema_pointer} =
            $context->{current_schema_pointer} . "/" . $class->keyword . "/" . $i;
        $context->validate($sub_schema, $instance);
    }
}

1;
