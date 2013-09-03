package JSV::Keyword::Draft4::MultipleOf;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_NUMERIC(); }
sub keyword { "multipleOf" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "number" || $opts->{type} eq "integer") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);
    my $result = $instance / $keyword_value;

    if ($result - int($result) == 0) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance doesn't multiple of schema value",
            $opts,
        );
    }
}

1;
