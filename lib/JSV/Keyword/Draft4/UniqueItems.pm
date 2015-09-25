package JSV::Keyword::Draft4::UniqueItems;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use List::MoreUtils qw(uniq);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ARRAY(); }
sub keyword() { "uniqueItems" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $keyword_value = $class->keyword_value($schema);

    if ($keyword_value) {
        $context->json->canonical(1);
        my @unique = uniq map {
            $context->json->encode($_)
        } @$instance;

        if (scalar @unique != scalar @$instance) {
            $context->log_error("The instance array is not unique");
        }
        $context->json->canonical(0);
    }
}

1;
