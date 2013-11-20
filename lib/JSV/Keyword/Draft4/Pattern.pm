package JSV::Keyword::Draft4::Pattern;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_STRING(); }
sub keyword { "pattern" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return unless $context->current_type eq "string";

    my $keyword_value = $class->keyword_value($schema);

    if ($instance =~ m/$keyword_value/) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance doesn't match the pattern value",
            $context,
        );
    }
}

1;
