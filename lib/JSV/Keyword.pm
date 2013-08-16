package JSV::Keyword;

use strict;
use warnings;

use Carp;
use JSV::Util::Type qw(detect_instance_type);
use Exporter qw(import);

our @EXPORT_OK = qw(
    INSTANCE_TYPE_NUMERIC
    INSTANCE_TYPE_STRING
    INSTANCE_TYPE_ARRAY
    INSTANCE_TYPE_OBJECT
    INSTANCE_TYPE_ANY
);

our %EXPORT_TAGS = (
    constants => [qw(
        INSTANCE_TYPE_NUMERIC
        INSTANCE_TYPE_STRING
        INSTANCE_TYPE_ARRAY
        INSTANCE_TYPE_OBJECT
        INSTANCE_TYPE_ANY
    )]
);

sub INSTANCE_TYPE_NUMERIC () { 1; }
sub INSTANCE_TYPE_STRING () { 2; }
sub INSTANCE_TYPE_ARRAY () { 3; }
sub INSTANCE_TYPE_OBJECT () { 4; }
sub INSTANCE_TYPE_ANY () { 5; }

sub instance_type {
    croak "instance_type method is abstract method";
}

sub keyword {
    croak "keyword method is abstract method";
}

sub has_keyword {
    my ($class, $schema, $keyword) = @_;
    $keyword ||= $class->keyword;

    exists $schema->{$keyword} ? 1 : 0;
}

sub keyword_value {
    my ($class, $schema, $keyword) = @_;
    $keyword ||= $class->keyword;
    return $schema->{$keyword};
}

sub initialize_args {
    my ($class, $schema, $instance, $opts) = @_;
    $opts->{type}           ||= detect_instance_type($instance);
    $opts->{pointer_tokens} ||= [];

    $opts->{keyword}  = $class->keyword;
}

1;
