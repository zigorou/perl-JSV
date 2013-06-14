package JSV::Keyword::Maximum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Exception;

sub keyword { "maximum" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "number" || $opts->{type} eq "integer") {
        return 1;
    }

    my $maximum           = $class->keyword_value($schema);
    my $exclusive_maximum = $class->keyword_value($schema, "exclusiveMaximum") || JSON::false;

    unless ($exclusive_maximum) {
        if ($instance <= $maximum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is greater than maximum keyword value",
                $opts,
            );
        }
    }
    else {
        if ($instance < $maximum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is greater than or equals maximum keyword value",
                $opts,
            );
        }
    }
}

1;
