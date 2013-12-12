package JSV::Util::Type;

use strict;
use warnings;
use Exporter qw(import);

use B;
use Carp;
use Scalar::Util qw(blessed);
use JSON;

our @EXPORT_OK = (
    qw/detect_instance_type/
);

our %REF_TYPE_MAP = (
    HASH  => "object",
    ARRAY => "array",
);

sub detect_instance_type {
    my ($instance) = @_;

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

1;
