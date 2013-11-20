package JSV::Context;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/
        json
        reference
        keyword
        environment
        environment_keywords
        last_exception
        resolved_schema
        original_schema
        throw_error
        pointer_tokens
    /]
);

use Scope::Guard qw(guard);
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub current_type {
    my ($self, $type) = @_;
    return $self->{current_type} unless $type;

    my $original_type = $self->{current_type};
    $self->{current_type} = $type;
    return guard {
        $self->{current_type} = $original_type;
    };
}

sub instance_type_keywords {
    my ($self, $instance_type) = @_;
    return @{$self->environment_keywords->{$self->environment}{$instance_type}};
}

sub validate {
    my ($self, $schema, $instance) = @_;

    use Data::Dump qw/dump/;
    warn dump $instance if $ENV{JSV_DEBUG};
    warn detect_instance_type($instance) if $ENV{JSV_DEBUG};

    my $guard = $self->current_type(detect_instance_type($instance));
    warn $self->current_type if $ENV{JSV_DEBUG};

    my $rv;
    eval {
        for ($self->instance_type_keywords(INSTANCE_TYPE_ANY)) {
            $self->keyword($_->keyword);
            $_->validate($self, $schema, $instance);
        }

        if ($self->current_type eq "integer" || $self->current_type eq "number") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_NUMERIC)) {
                $self->keyword($_->keyword);
                $_->validate($self, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "string") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_STRING)) {
                $self->keyword($_->keyword);
                $_->validate($self, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "array") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_ARRAY)) {
                $self->keyword($_->keyword);
                $_->validate($self, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "object") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_OBJECT)) {
                $self->keyword($_->keyword);
                $_->validate($self, $schema, $instance);
            }
        }

        $rv = 1;
    };
    if (my $e = $@) {
        $self->last_exception($e);
        if ($self->throw_error) {
            croak $e;
        }
        $rv = 0;
    }

    return $rv;
}

1;
