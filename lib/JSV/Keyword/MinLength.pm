package JSV::Keyword::MinLength;

use strict;
use warnings;
use parent qw(JSV::Keyword);

sub keyword { "minLength" }

sub validate {
    my ($class, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "string") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    if (length($instance) >= $keyword_value) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance length is less than minLength value",
            $opts,
        );
    }
}

1;
