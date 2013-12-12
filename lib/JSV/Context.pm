package JSV::Context;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/
        keywords
        reference
        original_schema
        throw_error
        throw_immediate
        enable_history
        enable_format
        formats
        history
        json
        loose_type
    /],
    ro  => [qw/
        errors
        current_type
        current_keyword
        current_pointer
        current_instance
        current_schema
    /],
);

use Carp qw(croak);
use JSON;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use JSV::Result;

sub validate {
    my ($self, $schema, $instance) = @_;

    local $self->{current_type} = detect_instance_type($instance, $self->{loose_type});

    my $rv;
    eval {
        for (@{ $self->keywords->{INSTANCE_TYPE_ANY()} }) {
            next unless exists $schema->{$_->keyword};
            $self->apply_keyword($_, $schema, $instance);
        }

        if ($self->current_type eq "integer" || $self->current_type eq "number") {
            for (@{ $self->keywords->{INSTANCE_TYPE_NUMERIC()} }) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "string") {
            for (@{ $self->keywords->{INSTANCE_TYPE_STRING()} }) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "array") {
            for (@{ $self->keywords->{INSTANCE_TYPE_ARRAY()} }) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "object") {
            for (@{ $self->keywords->{INSTANCE_TYPE_OBJECT()} }) {
                next unless exists $schema->{$_->keyword};
                $self->apply_keyword($_, $schema, $instance);
            }
        }

        $rv = JSV::Result->new(
            ($self->enable_history ? (history => $self->history) : ()),
        );
    };
    if ( scalar @{ $self->errors } ) {
        $rv = JSV::Result->new(
            errors => $self->errors,
            ($self->enable_history ? (history => $self->history) : ()),
        );
        if ( $self->throw_error ) {
            croak $rv;
        }
    }

    return $rv;
}

sub apply_keyword {
    my ($self, $keyword, $schema, $instance) = @_;

    local $self->{current_keyword}  = $_->keyword;
    local $self->{current_schema}   = $schema;
    local $self->{current_instance} = $instance;

    $_->validate($self, $schema, $instance);

    if ( $ENV{JSV_DEBUG} || $self->enable_history ) {
        push @{ $self->history }, +{
            keyword  => $self->current_keyword,
            pointer  => $self->current_pointer,
            schema   => $self->current_schema,
            instance => $self->resolve_current_instance,
        };
    }
}

sub log_error {
    my ($self, $message) = @_;

    my $error = +{
        keyword  => $self->current_keyword,
        pointer  => $self->current_pointer,
        schema   => $self->current_schema,
        instance => $self->resolve_current_instance,
        message  => $message,
    };

    if ( $ENV{JSV_DEBUG} ) {
        require Data::Dump;
        warn "history = " . Data::Dump::dump($self->history);
        warn "error = " . Data::Dump::dump($error);
    }

    if ( $self->throw_immediate ) {
        croak JSV::Result->new(
            error => $error,
            ($self->enable_history ? (history => $self->history) : ()),
        );
    }
    else {
        push @{ $self->{errors} }, $error;
    }
}

sub resolve_current_instance {
    my $self = shift;

    my $instance;
    if ( ref $self->current_instance ) {
        if ( $self->current_instance == JSON::true ) {
            $instance = "true";
        }
        elsif ( $self->current_instance == JSON::false ) {
            $instance = "false";
        }
    }
    else {
        $instance = $self->current_instance;
    }

    return $instance;
}

1;
