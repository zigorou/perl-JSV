package JSV::Keyword::Draft4::Pattern;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_STRING(); }
sub keyword() { "pattern" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $keyword_value = $class->keyword_value($schema);

    if ($instance !~ m/$keyword_value/) {
        $context->log_error("The instance doesn't match the pattern value");
    }
}

1;
