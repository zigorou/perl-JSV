package JSV::Keyword::Type;

use strict;
use warnings;

use B;
use JSON;
use Scalar::Util;

sub validate {
    my ($keyword_value, $instance) = @_;

    my $rv;
    if (ref $keyword_value eq "ARRAY") {
        for my $type (@$keyword_value) {
            $rv = validate($type, $instance);
            last if $rv;
        }
    }
    else {
        my $type_validator = __PACKAGE__->can("validate_type_" . $keyword_value);
        return $type_validator->($instance);
    }
}

sub validate_type_array {
    my $instance = shift;
    return ref $instance eq "ARRAY" ? 1 : 0;
}

sub validate_type_boolean {
    my $instance = shift;
    return JSON::is_bool($instance) ? 1 : 0;
}

sub validate_type_integer {
    my $instance = shift;
    my $flags = B::svref_2object(\$instance);
    return ( ($flags & B::SVp_IOK) and !($flags & (B::SVp_NOK | B::SVp_POK)) ) ? 1 : 0;
}

sub validate_type_null {
    my $instance = shift;
    return !defined $instance ? 1 : 0;
}

sub validate_type_number {
    my $instance = shift;
    my $flags = B::svref_2object(\$instance);
    return ( ($flags & ( B::SVp_IOK | B::SVp_NOK )) and !($flags &  B::SVp_POK) ) ? 1 : 0;
}

sub validate_type_object {
    my $instance = shift;
    return (ref $instance eq "HASH" && !blessed $instance) ? 1 : 0;
}

sub validate_type_string {
    my $instance = shift;
    my $flags = B::svref_2object(\$instance);
    return ( $flags & B::SVp_POK ) ? 1 : 0;
}

1;
