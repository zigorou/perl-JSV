package JSV::Keyword::Draft4::Minimum;

use strict;
use warnings;
use parent qw(JSV::Keyword);
use JSON;

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_NUMERIC(); }
sub keyword { "minimum" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "number" || $opts->{type} eq "integer") {
        return 1;
    }

    my $minimum           = $class->keyword_value($schema);
    my $exclusive_minimum = $class->keyword_value($schema, "exclusiveMinimum") || JSON::false;

    unless ($exclusive_minimum) {
        if ($instance >= $minimum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is less than minimum keyword value",
                $opts,
            );
        }
    }
    else {
        if ($instance > $minimum) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance value is less than or equals minimum keyword value",
                $opts,
            );
        }
    }
}

1;
