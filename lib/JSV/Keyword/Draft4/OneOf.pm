package JSV::Keyword::Draft4::OneOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "oneOf" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);

    my $one_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$one_of) {
        my $rv = $context->validate($sub_schema, $instance);
        $valid_cnt += $rv;
    }

    unless ($valid_cnt == 1) {
        JSV::Exception->throw(
            "The instance is not valid to one of schemas",
            $context,
        );
    }

    return 1;
}

1;
