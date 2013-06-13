package JSV::Keyword::Type;

use strict;
use warnings;

use B;
use JSON;
use Scalar::Util qw(blessed);

sub validate {
    my ($class, $schema, $instance) = @_;
    my $rv;

    return 1 unless exists $schema->{type};

    my $keyword_value = $schema->{type};

    if (ref $keyword_value eq "ARRAY") {
        for my $type (@$keyword_value) {
            $rv = $class->validate_singular_type($type, $instance);
            last if $rv;
        }
        return $rv;
    }
    else {
        return $class->validate_singular_type($keyword_value, $instance);
    }
}

sub validate_singular_type {
    my ($class, $type, $instance) = @_;
    return $class->can("validate_type_" . $type)->($class, $instance);
}

sub validate_type_array {
    my ($class, $instance) = @_;
    return ref $instance eq "ARRAY" ? 1 : 0;
}

sub validate_type_boolean {
    my ($class, $instance) = @_;
    return JSON::is_bool($instance) ? 1 : 0;
}

sub validate_type_integer {
    my ($class, $instance) = @_;
    my $flags = B::svref_2object(\$instance)->FLAGS;
    return $flags & B::SVp_IOK ? 1 : 0;
}

sub validate_type_null {
    my ($class, $instance) = @_;
    return !defined $instance ? 1 : 0;
}

sub validate_type_number {
    my ($class, $instance) = @_;
    my $flags = B::svref_2object(\$instance)->FLAGS;
    return $flags & ( B::SVp_IOK | B::SVp_NOK ) ? 1 : 0;
}

sub validate_type_object {
    my ($class, $instance) = @_;
    return (ref $instance eq "HASH" && !blessed $instance) ? 1 : 0;
}

sub validate_type_string {
    my ($class, $instance) = @_;
    my $flags = B::svref_2object(\$instance)->FLAGS;
    return $flags & B::SVp_POK ? 1 : 0;
}

1;
