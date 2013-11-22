package JSV::Keyword::Draft4::Properties;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { 'properties' }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $properties = $class->keyword_value($schema) || {};
    my $pattern_properties = $class->keyword_value($schema, "patternProperties") || {};

    my @patterns = ();
    my @pattern_schemas = ();
    for my $pattern (keys %$pattern_properties) {
        push(@patterns, qr/$pattern/);
        push(@pattern_schemas, $pattern_properties->{$pattern});
    }

    my $additional_properties = $class->keyword_value($schema, "additionalProperties");
    my $additional_properties_type = detect_instance_type($schema->{additionalProperties});
    my %s = map { $_ => undef } keys %$instance;

    for my $property (keys %$instance) {
        local $context->{current_pointer} .= "/" . $property;

        if (exists $properties->{$property}) {
            $context->validate($properties->{$property}, $instance->{$property});
            delete $s{$property};
        }

        for (my $i = 0, my $l = scalar(@patterns); $i < $l; $i++) {
            next unless ($property =~ m/$patterns[$i]/);
            $context->validate($pattern_schemas[$i], $instance->{$property});
            delete $s{$property};
        }

        if (exists $s{$property} && $additional_properties_type eq "object") {
            $context->validate($additional_properties, $instance->{$property});
        }
    }

    if ($additional_properties_type eq "boolean" && !$additional_properties) {
        if (keys %s > 0) {
            $context->log_error("Not allowed properties are existence (properties: %s)", join(", ", keys %s));
        }
    }
}

1;
