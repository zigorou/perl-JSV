package JSV::Keyword::Draft4::OneOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "oneOf" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $one_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$one_of) {
        local $context->{errors} = [];
        $context->validate($sub_schema, $instance);
        $valid_cnt += 1 unless scalar @{ $context->{errors} };
    }

    unless ($valid_cnt == 1) {
        $context->log_error("The instance is not matched to one of schemas");
    }
}

1;
