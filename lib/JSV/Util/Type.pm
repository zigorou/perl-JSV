package JSV::Util::Type;

use strict;
use warnings;
use Exporter qw(import);

use B;
use Carp;
use Scalar::Util qw(blessed looks_like_number);
use JSON;

our @EXPORT_OK = (qw/
    detect_instance_type
    detect_instance_type_loose
    escape_json_pointer
    loose_type_match
/);

our %REF_TYPE_MAP = (
    HASH  => "object",
    ARRAY => "array",
);

sub detect_instance_type {
    my $instance = shift;

    my $ref_type;

    if (!defined $instance) {
        return "null";
    }
    elsif ($ref_type = ref $instance) {
        if (!blessed $instance) {
            return $REF_TYPE_MAP{$ref_type};
        }
        elsif (JSON::is_bool($instance)) {
            return "boolean";
        }
        else {
            croak(sprintf("Unknown reference type (ref_type: %s)", $ref_type));
        }
    }
    else {
        my $flags = B::svref_2object(\$instance)->FLAGS;

        if (( $flags & B::SVp_IOK ) == B::SVp_IOK) {
            return "integer";
        }
        elsif (( $flags & B::SVp_NOK ) == B::SVp_NOK ) {
            return "number";
        }
        elsif (( $flags & B::SVp_POK ) == B::SVp_POK) {
            return "string";
        }
        else {
            croak(sprintf("Unknown type (flags: %s)", $flags));
        }
    }
}

sub detect_instance_type_loose {
    my ($instance) = @_;

    my $type_strict = detect_instance_type($instance);

    if ( $type_strict eq "integer" ) {
        return "integer_or_string";
    }
    elsif ( $type_strict eq "number" ) {
        return "number_or_string";
    }
    elsif ( $type_strict eq "string" ) {
        if ( looks_like_number($instance) ) {
            return "integer_or_string" if $instance =~ m/^(?:[+-])?[1-9]?\d+$/;
            return "number_or_string";
        }
    }
    return $type_strict;
}

sub escape_json_pointer {
    my $property = shift;
    return unless defined $property;

    # according to http://tools.ietf.org/html/rfc6901#section-4
    $property =~ s!~!~0!g; # replace tilde first
    $property =~ s!/!~1!g;

    return $property;
}

sub loose_type_match {
    my ($type1, $type2) = @_;

    my @scalar_types = qw/boolean integer number string/;

    return unless grep { $type1 eq $_ } @scalar_types;
    return unless grep { $type2 eq $_ } @scalar_types;

    return 1;
}

1;
