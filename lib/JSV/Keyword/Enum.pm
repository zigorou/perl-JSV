package JSV::Keyword::Enum;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Util::Type qw(detect_instance_type);
use JSON;
use List::Util qw(first);

sub keyword { "enum" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless ( $class->has_keyword($schema) );

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $enum = $class->keyword_value($schema);
    my $instance_as_json = $validator->json->encode($instance);
    my $matched = first { $validator->json->encode($_) eq $instance_as_json } @$enum;

    if (defined $matched) {
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
