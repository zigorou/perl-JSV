package JSV::Keyword::OneOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Util::Type qw(detect_instance_type);
use JSV::Exception;

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

        my $rv = $validator->validate($sub_schema, $instance, $opts);
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
