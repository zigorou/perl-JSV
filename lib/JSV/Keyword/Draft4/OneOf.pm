package JSV::Keyword::Draft4::OneOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "oneOf" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $one_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$one_of) {
        local $opts->{type}  = detect_instance_type($instance);
        local $opts->{throw} = 0;

        my $rv = $validator->_validate($sub_schema, $instance, $opts);
        $valid_cnt += $rv;
    }

    unless ($valid_cnt == 1) {
        JSV::Exception->throw(
            "The instance is not valid to one of schemas",
            $opts,
        );
    }

    return 1;
}

1;
