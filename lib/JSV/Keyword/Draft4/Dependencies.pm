package JSV::Keyword::Draft4::Dependencies;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use List::Util qw(first);

sub instance_type { INSTANCE_TYPE_OBJECT(); }
sub keyword { "dependencies" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless ( $class->has_keyword($schema) );

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "object") {
        return 1;
    }

    my $dependencies = $class->keyword_value($schema);
    $dependencies ||= {};

    for my $property (keys %$dependencies) {
        next unless (exists $instance->{$property});

        local $opts->{pointer_tokens};
        push(@{$opts->{pointer_tokens}}, $property);

        if (ref $dependencies->{$property} eq "ARRAY") {
            my $found_against_dependency = first { !exists $instance->{$_} } @{$dependencies->{$property}};
            if ($found_against_dependency) {
                JSV::Exception->throw(
                    sprintf("%s property has dependency on the %s field", $property, $found_against_dependency), 
                    $opts,
                );
            }
        }
        elsif (ref $dependencies->{$property} eq "HASH") {
            local $opts->{type}  = detect_instance_type($instance);
            local $opts->{throw} = 1;

            $validator->validate($dependencies->{$property}, $instance, $opts);
        }
    }

    return 1;
}

1;
