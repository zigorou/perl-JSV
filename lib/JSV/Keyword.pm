package JSV::Keyword;

use strict;
use warnings;

use Carp;
use JSV::Util::Type qw(detect_instance_type);

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
