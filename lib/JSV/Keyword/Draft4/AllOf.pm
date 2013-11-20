package JSV::Keyword::Draft4::AllOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "allOf" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);

    my $all_of = $class->keyword_value($schema);

    for my $sub_schema (@$all_of) {
        $context->validate($context, $sub_schema, $instance);
    }

    return 1;
}

1;
