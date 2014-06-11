package JSV::Util::Compare;

use strict;
use warnings;
use Exporter qw(import);

use Carp qw(croak);

use JSV::Util::Type qw(detect_instance_type detect_instance_type_loose);

our @EXPORT_OK = (
    qw/deep_eq/
);

# Utilizes a queue to avoid stack overflow.
sub deep_eq {
    my ($x, $y, $loose_type) = @_;

    my @queue = ();
    push(@queue, [$x, $y]);

    while(@queue){
        ($x, $y) = @{shift @queue};

        my $type_x = detect_instance_type($x);
        my $type_y = detect_instance_type($y);

        if ( $type_x ne $type_y ) {
            if ( $loose_type ) {
                my $type_x_loose = detect_instance_type_loose($x);
                my $type_y_loose = detect_instance_type_loose($y);

                return $type_x_loose eq $type_y_loose && $x == $y;
            }
            return 0;
        }

        if ( $type_x eq "null" ) {
            # nop
        }
        elsif ( $type_x eq "boolean" || $type_x eq "integer" || $type_x eq "number" ) {
            return if $x != $y;
        }
        elsif ( $type_x eq "string" ) {
            return if $x ne $y;
        }
        elsif ( $type_x eq "array" ) {
            return if @$x ne @$y;
            for ( my $i = 0; $i < @$x; ++$i ) {
                push(@queue, [$x->[$i], $y->[$i]]);
            }
        }
        elsif ( $type_x eq "object" ) {
            return if %$x ne %$y;
            for my $key (keys %$x) {
                return unless defined $y->{$key};
                push(@queue, [$x->{$key}, $y->{$key}]);
            }
        }
        else {
            croak sprintf('unknown type: %s', $type_x);
        }
    }

    return 1;
}
