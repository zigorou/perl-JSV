package JSV::Keyword::Draft4::Properties;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_OBJECT(); }
sub keyword { "properties" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    unless (
        $class->has_keyword($schema) || 
        $class->has_keyword($schema, "additionalProperties") || 
        $class->has_keyword($schema, "patternProperties")
    ) {
        return 1;
    }

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "object") {
        return 1;
    }

    my $properties = $class->keyword_value($schema);
    $properties ||= {};

    my $pattern_properties = $class->keyword_value($schema, "patternProperties");
    $pattern_properties ||= {};
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
        local $opts->{pointer_tokens};
        push(@{$opts->{pointer_tokens}}, $property);
        local $opts->{type}  = detect_instance_type($instance->{$property});
        local $opts->{throw} = 1;

        if (exists $properties->{$property}) {
            $validator->_validate($properties->{$property}, $instance->{$property}, $opts);
            delete $s{$property};
        }

        for (my $i = 0, my $l = scalar(@patterns); $i < $l; $i++) {
            next unless ($property =~ m/$patterns[$i]/);
            $validator->_validate($pattern_schemas[$i], $instance->{$property}, $opts);
            delete $s{$property};
        }

        if (exists $s{$property} && $additional_properties_type eq "object") {
            $validator->_validate($additional_properties, $instance->{$property}, $opts);
        }
    }

    if ($additional_properties_type eq "boolean" && !$additional_properties) {
        if (keys %s > 0) {
            JSV::Exception->throw(
                sprintf("Not allowed properties are existence (properties: %s)", join(", ", keys %s)),
                $opts,
            );
        }
    }

    return 1;
}

1;
