package JSV::Keyword::Draft4::Type;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use B;
use JSON;
use List::Util qw(first);
use Scalar::Util qw(blessed);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { "type" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);

    my $keyword_value = $class->keyword_value($schema);

    if (ref $keyword_value eq "ARRAY") {
        if ( first { $class->validate_singular_type( $_, $context->current_type ) } @$keyword_value ) {
            return 1;
        }
        else {
            JSV::Exception->throw("instance type doesn't match schema type list", $context);
        }
    }
    else {
        if ($class->validate_singular_type( $keyword_value, $context->current_type )) {
            return 1;
        }
        else {
            JSV::Exception->throw("instance type doesn't match schema type", $context);
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
