package JSV::Keyword::Draft4::Id;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { 'id' }
sub keyword_priority() { 7; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    push @{ $context->{schema_pointer_history} }, $context->{current_schema_pointer};
    $context->{current_schema_pointer} = $class->keyword_value($schema);
    
    $context->register_cleanup_callback(sub {
        $context->{current_schema_pointer} = pop @{ $context->{schema_pointer_history} };
    });

}

1;
