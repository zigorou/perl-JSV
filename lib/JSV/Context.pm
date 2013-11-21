package JSV::Context;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/
        json
        reference
        environment
        environment_keywords
        resolved_schema
        original_schema
        throw_error
        pointer_tokens
    /],
    ro  => [qw/
        errors
        current_type
        current_keyword
        current_instance
        current_schema
    /],
);

use Scope::Guard qw(guard);
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);

sub instance_type_keywords {
    my ($self, $instance_type) = @_;
    return @{$self->environment_keywords->{$self->environment}{$instance_type}};
}

sub validate {
    my ($self, $schema, $instance) = @_;

    local $self->{current_type} = detect_instance_type($instance);

    my $rv;
    eval {
        for ($self->instance_type_keywords(INSTANCE_TYPE_ANY)) {
            next unless exists $schema->{$_->keyword};
            $self->apply_keyword($_, $schema, $instance);
        }

        if ($self->current_type eq "integer" || $self->current_type eq "number") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_NUMERIC)) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "string") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_STRING)) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "array") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_ARRAY)) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "object") {
            for ($self->instance_type_keywords(INSTANCE_TYPE_OBJECT)) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }

        $rv = 1;
    };
    if ( scalar @{ $self->errors } ) {
        if ($self->throw_error) {
            croak $self->errors;
        }
        $rv = 0;
    }

    return $rv;
}

sub apply_keyword {
    my ($self, $keyword, $schema, $instance) = @_;

    local $self->{current_keyword}  = $_->keyword;
    local $self->{current_schema}   = $schema;
    local $self->{current_instance} = $instance;

    $_->validate($self, $schema, $instance);
}

sub log_error {
    my ($self, $message) = @_;

    push @{ $self->{errors} }, +{
        keyword  => $self->current_keyword,
        pointer  => join "/", @{ $self->pointer_tokens },
        schema   => $self->current_schema,
        instance => $self->current_instance,
        message  => $message,
    };
}

1;
