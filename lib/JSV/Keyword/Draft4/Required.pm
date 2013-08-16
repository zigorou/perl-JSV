package JSV::Keyword::Draft4::Required;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_OBJECT(); }
sub keyword { "required" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "object") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    my @missing_properties = ( grep { !exists $instance->{$_} } @$keyword_value );
    if ( @missing_properties == 0 ) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            sprintf("The instance properties has not required properties (missing: %s)", join(", ", @missing_properties)),
            $opts,
        );
    }
}

1;
