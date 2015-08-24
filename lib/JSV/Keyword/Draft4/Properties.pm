package JSV::Keyword::Draft4::Properties;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type escape_json_pointer);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { 'properties' }
sub additional_keywords() { [qw/additionalProperties patternProperties/]; }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $properties = $class->keyword_value($schema) || {};
    my $pattern_properties = $class->keyword_value($schema, "patternProperties") || {};

    my @patterns = ();
    my @pattern_schemas = ();
    my @original_patterns = ();
    for my $pattern (keys %$pattern_properties) {
        push(@patterns, qr/$pattern/);
        push(@pattern_schemas, $pattern_properties->{$pattern});
        push(@original_patterns, $pattern);
    }

    my $additional_properties = $class->keyword_value($schema, "additionalProperties");
    my $additional_properties_type = detect_instance_type($schema->{additionalProperties});
    my %s = map { $_ => undef } keys %$instance;

    for my $property (keys %$instance) {
        local $context->{current_pointer} = $context->{current_pointer} . "/" . escape_json_pointer( $property );

        if (exists $properties->{$property}) {
            local $context->{current_schema_pointer} =
                $context->{current_schema_pointer} . "/properties/" . escape_json_pointer( $property );
            $context->validate($properties->{$property}, $instance->{$property});
            delete $s{$property};
        }

        for (my $i = 0, my $l = scalar(@patterns); $i < $l; $i++) {
            next unless ($property =~ m/$patterns[$i]/);
            local $context->{current_schema_pointer} =
                $context->{current_schema_pointer} . "/patternProperties/" . escape_json_pointer( $original_patterns[$i] );
            $context->validate($pattern_schemas[$i], $instance->{$property});
            delete $s{$property};
        }

        if (exists $s{$property} && $additional_properties_type eq "object") {
            local $context->{current_schema_pointer} =
                $context->{current_schema_pointer} . "/additionalProperties";
            $context->validate($additional_properties, $instance->{$property});
        }
    }

    if ($additional_properties_type eq "boolean" && !$additional_properties) {
        if (keys %s > 0) {
            # TODO: provide pointer for each extra property
            # (to avoid parsing error message and don't depend on its format)
            $context->log_error(sprintf("Not allowed properties exist (properties: %s)", join(", ", keys %s)));
        }
    }
}

1;
