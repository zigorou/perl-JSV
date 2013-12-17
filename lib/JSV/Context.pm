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

    local $self->{current_type} = detect_instance_type($instance);

    my $rv;
    eval {
        for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_ANY()} }) {
            next unless exists $schema->{$keyword->keyword};
            $self->apply_keyword($keyword, $schema, $instance);
        }

        if ($self->is_matched_types(qw/integer number/)) {
            for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_NUMERIC()} }) {
                next unless exists $schema->{$keyword->keyword};
                $self->apply_keyword($keyword, $schema, $instance);
            }
        }
        elsif ($self->is_matched_types( $self->{loose_type} ? qw/string integer number/ : qw/string/ )) {
            for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_STRING()} }) {
                next unless exists $schema->{$keyword->keyword};
                $self->apply_keyword($keyword, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "array") {
            for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_ARRAY()} }) {
                next unless exists $schema->{$keyword->keyword};
                $self->apply_keyword($keyword, $schema, $instance);
            }
        }
        elsif ($self->current_type eq "object") {
            for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_OBJECT()} }) {
                ### for addtionalProperties, patternProperties keyword without properties keyword
                next unless ( ( grep { defined $_ && exists $schema->{$_} } ($keyword->keyword, @{$keyword->additional_keywords}) ) > 0 );
                # next unless exists $schema->{$_->keyword};
                $self->apply_keyword($keyword, $schema, $instance);
            }
        }

        $rv = JSV::Result->new(
            ($self->enable_history ? (history => $self->history) : ()),
        );
    };
    if ( my $e = $@ ) {
        $self->log_error(sprintf("Unexpected error: %s", $e));
    }

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

    local $self->{current_keyword}  = $keyword->keyword;
    local $self->{current_schema}   = $schema;
    local $self->{current_instance} = $instance;

    $keyword->validate($self, $schema, $instance);

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
    if ( JSON::is_bool($self->current_instance) ) {
        if ( $self->current_instance == JSON::true ) {
            $instance = "true";
        }
        else {
            $instance = "false";
        }
    }
    else {
        $instance = $self->current_instance;
    }

    return $instance;
}

sub is_matched_types {
    my ($self, @types) = @_;
    return (grep { $self->{current_type} eq $_ } @types) > 0 ? 1 : 0;
}

1;
