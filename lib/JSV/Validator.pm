package JSV::Validator;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/json reference last_exception resolved_schema/]
);
use Clone qw(clone);
use JSON;
use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type);
use JSV::Reference;
use Module::Pluggable::Object;

my %supported_environments = (
    draft4 => "Draft4"
);
my %environment_keywords = ();

sub load_environments {
    my ($class, @environments) = @_;

    for my $environment (@environments) {
        next unless (exists $supported_environments{$environment});
        my $finder = Module::Pluggable::Object->new(
            search_path => ["JSV::Keyword::" . $supported_environments{$environment}],
            require => 1,
        );

        $environment_keywords{$environment} =  {
            INSTANCE_TYPE_NUMERIC() => [],
            INSTANCE_TYPE_STRING()  => [],
            INSTANCE_TYPE_ARRAY()   => [],
            INSTANCE_TYPE_OBJECT()  => [],
            INSTANCE_TYPE_ANY()     => [],
        };
        my @keywords = 
            sort { $a->keyword_priority <=> $b->keyword_priority }
            $finder->plugins;

        for my $keyword (@keywords) {
            my $type = $keyword->instance_type;
            push(@{$environment_keywords{$environment}{$type}}, $keyword);
        }
    }
}

sub new {
    my $class = shift;
    my %args  = @_;
    %args = (
        environment => 'draft4',
        %args,
    );

    ### RECOMMENDED: you should do to preloading environment before calling constructor
    unless (exists $environment_keywords{$args{environment}}) {
        $class->load_environments($args{environment});
    }

    bless {
        last_exception => undef,
        resolved_schema => undef,
        json           => JSON->new->allow_nonref,
        reference      => JSV::Reference->new,
        %args,
    } => $class;
}

sub validate {
    my ($self, $schema, $instance) = @_;

    my $cloned_schema = clone($schema);
    my $opts = +{
        type => detect_instance_type($instance),
        schema => $cloned_schema,
        throw          => 0,
        pointer_tokens => [],
    };

    my $rv;
    $self->{last_exception} = undef;
    $self->{resolved_schema} = undef;
    $rv = $self->_validate($cloned_schema, $instance, $opts);
    $self->{resolved_schema} = $cloned_schema;

    return $rv;
}

sub register_schema {
    shift->{reference}->register_schema(@_);
}

sub unregister_schema {
    shift->{reference}->unregister_schema(@_);
}

sub _validate {
    my ($self, $schema, $instance, $opts) = @_;

    $opts ||= {};
    %$opts = (
        exists $opts->{type} ? () : (
            type => detect_instance_type($instance)
        ),
        exists $opts->{schema} ? () : (
            schema => $schema
        ),
        throw          => 1,
        pointer_tokens => [],
        %$opts,
    );

    my $rv;

    eval {
        for ($self->_instance_type_keywords(INSTANCE_TYPE_ANY)) {
            $_->validate($self, $schema, $instance, $opts);
        }

        if ($opts->{type} eq "integer" || $opts->{type} eq "number") {
            for ($self->_instance_type_keywords(INSTANCE_TYPE_NUMERIC)) {
                $_->validate($self, $schema, $instance, $opts);
            }
        }
        elsif ($opts->{type} eq "string") {
            for ($self->_instance_type_keywords(INSTANCE_TYPE_STRING)) {
                $_->validate($self, $schema, $instance, $opts);
            }
        }
        elsif ($opts->{type} eq "array") {
            for ($self->_instance_type_keywords(INSTANCE_TYPE_ARRAY)) {
                $_->validate($self, $schema, $instance, $opts);
            }
        }
        elsif ($opts->{type} eq "object") {
            for ($self->_instance_type_keywords(INSTANCE_TYPE_OBJECT)) {
                $_->validate($self, $schema, $instance, $opts);
            }
        }

        $rv = 1;
    };
    if (my $e = $@) {
        $self->last_exception($e);
        if ($opts->{throw}) {
            croak $e;
        }
        $rv = 0;
    }

    return $rv;
}

sub _instance_type_keywords {
    my ($self, $instance_type) = @_;
    return @{$environment_keywords{$self->{environment}}{$instance_type}};
}

1;

__END__

=encoding utf-8

=head1 NAME

JSV::Validator - A perl implementation of JSON Schema validator

=head1 SYNOPSIS

  use feature qw(say);
  use JSV::Validator;

  JSV::Validator->load_environments("draft4");
  my $v = JSV::Validator->new(
    environment => "draft4"
  );

  my $schema = {
    type => "object",
    properties => {
      foo => { type => "integer" },
      bar => { type => "string" }
    },
    required => [ "foo" ]
  };

  say $v->validate($schema, {}); # invalid
  say $v->validate($schema, { foo => 1 }); # valid
  say $v->validate($schema, { foo => 10, bar => "xyz" }); # valid
  say $v->validate($schema, { foo => 1.2, bar => "xyz" }); # invalid

=head1 DESCRIPTION

=head1 METHODS

=head1 SEE ALSO

=over

=item L<http://json-schema.org/>

=item L<B>

=item L<Class::Accessor::Lite>

=item L<Data::Clone>

=item L<Exporter>

=item L<JSON>

=item L<JSON::Pointer>

=item L<List::Util>

=item L<List::MoreUtils>

=item L<Module::Pluggable::Object>

=item L<Scalar::Util>

=item L<URI>

=item L<URI::Split>

=back

=head1 LICENSE

Copyright (C) Toru Yamaguchi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=cut

