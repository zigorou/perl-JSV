package JSV::Keyword::Type;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use B;
use JSON;
use List::Util qw(first);
use Scalar::Util qw(blessed);

use JSV::Exception;
use JSV::Util::Type qw(detect_instance_type);

sub keyword { "type" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);
    my $keyword_value = $class->keyword_value($schema);

    if (ref $keyword_value eq "ARRAY") {
        if ( first { $class->validate_singular_type( $_, $opts->{type} ) } @$keyword_value ) {
            return 1;
        }
        else {
            JSV::Exception->throw("instance type doesn't match schema type list", $opts);
        }
    }
    else {
        if ($class->validate_singular_type( $keyword_value, $opts->{type} )) {
            return 1;
        }
        else {
            JSV::Exception->throw("instance type doesn't match schema type", $opts);
        }
    }
}

sub validate_singular_type {
    my ($class, $schema_type, $given_type) = @_;

    if ( $schema_type eq $given_type || ( $schema_type eq "number" && $given_type eq "integer") ) {
        return 1;
    }
    else {
        return 0;
    }
}

1;
