package JSV::Keyword::Draft4::UniqueItems;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use List::MoreUtils qw(uniq);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_ARRAY(); }
sub keyword { "uniqueItems" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "array") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    if ($keyword_value) {
        my @unique = uniq map {
            $validator->json->encode($_)
        } @$instance;

        if (scalar @unique == scalar @$instance) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance array is not unique",
                $opts,
            );
        }
    }
    else {
        return 1;
    }
}

1;
