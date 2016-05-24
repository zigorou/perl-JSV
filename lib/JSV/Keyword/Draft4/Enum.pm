package JSV::Keyword::Draft4::Enum;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);
use JSON;
use List::MoreUtils qw(any);
use Test::Deep qw(eq_deeply);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "enum" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $enum = $class->keyword_value($schema);

    my $is_valid
        = $context->loose_type
        ? any { ref $instance ? eq_deeply($instance, $_) : $instance eq $_ } @$enum
        : any { $context->json->encode($instance) eq $context->json->encode($_) } @$enum;

    unless ($is_valid) {
        $context->log_error("The instance value does not be included in the enum list");
    }
}

1;
