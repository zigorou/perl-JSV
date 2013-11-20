package JSV::Keyword::Draft4::AnyOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use JSV::Exception;

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "anyOf" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);

    my $any_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$any_of) {
        my $rv = $context->validate($sub_schema, $instance);
        $valid_cnt += $rv;
    }

    if ($valid_cnt == 0) {
        JSV::Exception->throw(
            "The instance is not valid to any of schemas",
            $context,
        );
    }

    return 1;
}

1;
