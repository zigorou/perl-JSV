package JSV::Keyword::Draft4::AllOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "allOf" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $all_of = $class->keyword_value($schema);

    for my $sub_schema (@$all_of) {
        local $opts->{type}  = detect_instance_type($instance);
        local $opts->{throw} = 1;

        $validator->_validate($sub_schema, $instance, $opts);
    }

    return 1;
}

1;
