package JSV::Keyword::Draft4::Format;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_STRING(); }
sub keyword() { "format" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return unless $context->enable_format;

    my $format = $class->keyword_value($schema);

    if ( my $format_validator = $context->formats->{$format} ) {
        unless ( $format_validator->($instance) ) {
            $context->log_error("The instance does not pass '$format' format check");
        }
    }
}

1;
