package JSV::Keyword::Draft4::Enum;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Exception;
use JSV::Util::Type qw(detect_instance_type);
use JSON;
use List::MoreUtils qw(firstidx);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "enum" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless ( $class->has_keyword($schema) );

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $enum = $class->keyword_value($schema);
    my $instance_as_json = $validator->json->encode($instance);
    my $matched_idx = firstidx { $instance_as_json eq $validator->json->encode($_); } @$enum;

    if ($matched_idx != -1) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            sprintf("The instance value does not be included in the enum list"),
            $opts
        );
    }
}

1;
