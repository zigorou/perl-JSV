package JSV::Keyword::Draft4::AnyOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use JSV::Exception;

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "anyOf" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $any_of = $class->keyword_value($schema);
    my $valid_cnt = 0;

    for my $sub_schema (@$any_of) {
        local $opts->{type}  = detect_instance_type($instance);
        local $opts->{throw} = 0;

        my $rv = $validator->_validate($sub_schema, $instance, $opts);
        $valid_cnt += $rv;
    }

    if ($valid_cnt == 0) {
        JSV::Exception->throw(
            "The instance is not valid to any of schemas",
            $opts,
        );
    }

    return 1;
}

1;
