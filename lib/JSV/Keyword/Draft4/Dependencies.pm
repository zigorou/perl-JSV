package JSV::Keyword::Draft4::Dependencies;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use List::Util qw(first);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { "dependencies" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $dependencies = $class->keyword_value($schema);
    $dependencies ||= {};

    for my $property (keys %$dependencies) {
        next unless (exists $instance->{$property});

        push(@{$context->pointer_tokens}, $property);

        if (ref $dependencies->{$property} eq "ARRAY") {
            my $found_against_dependency = first { !exists $instance->{$_} } @{$dependencies->{$property}};
            if ($found_against_dependency) {
                $context->log_error(sprintf("%s property has dependency on the %s field", $property, $found_against_dependency));
            }
        }
        elsif (ref $dependencies->{$property} eq "HASH") {
            $context->validate($dependencies->{$property}, $instance);
        }

        pop(@{$context->pointer_tokens});
    }
}

1;
