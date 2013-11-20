package JSV::Keyword::Draft4::UniqueItems;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use List::MoreUtils qw(uniq);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_ARRAY(); }
sub keyword { "uniqueItems" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "array";

    my $keyword_value = $class->keyword_value($schema);

    if ($keyword_value) {
        my @unique = uniq map {
            $context->json->encode($_)
        } @$instance;

        if (scalar @unique == scalar @$instance) {
            return 1;
        }
        else {
            JSV::Exception->throw(
                "The instance array is not unique",
                $context,
            );
        }
    }
    else {
        return 1;
    }
}

1;
