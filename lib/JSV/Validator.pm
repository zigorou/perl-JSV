package JSV::Validator;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/
        reference
        environment
        environment_keywords
        enable_history
        throw_error
        throw_immediate
    /]
);
use Clone qw(clone);
use JSON;
use JSV::Keyword qw(:constants);
use JSV::Reference;
use JSV::Context;
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
        environment    => 'draft4',
        enable_history => 0,
        reference      => JSV::Reference->new,
        %args,
    );

    ### RECOMMENDED: you should do to preloading environment before calling constructor
    unless (exists $environment_keywords{$args{environment}}) {
        $class->load_environments($args{environment});
    }

    bless {
        environment_keywords => \%environment_keywords,
        %args,
    } => $class;
}

sub validate {
    my ($self, $schema, $instance) = @_;

    my $context = JSV::Context->new(
        keywords               => +{
            INSTANCE_TYPE_ANY()     => $self->instance_type_keywords(INSTANCE_TYPE_ANY),
            INSTANCE_TYPE_NUMERIC() => $self->instance_type_keywords(INSTANCE_TYPE_NUMERIC),
            INSTANCE_TYPE_STRING()  => $self->instance_type_keywords(INSTANCE_TYPE_STRING),
            INSTANCE_TYPE_ARRAY()   => $self->instance_type_keywords(INSTANCE_TYPE_ARRAY),
            INSTANCE_TYPE_OBJECT()  => $self->instance_type_keywords(INSTANCE_TYPE_OBJECT),
        },
        reference       => $self->reference,
        environment     => $self->environment,
        original_schema => $schema,
        throw_error     => $self->throw_error,
        throw_immediate => $self->throw_immediate,
        enable_history  => $self->enable_history,
        history         => [],
        errors          => [],
        pointer_tokens  => [],
        json            => JSON->new->allow_nonref,
    );

    return $context->validate($schema, $instance);
}

sub instance_type_keywords {
    my ($self, $instance_type) = @_;
    return $self->environment_keywords->{$self->environment}{$instance_type};
}

sub register_schema {
    shift->reference->register_schema(@_);
}

sub unregister_schema {
    shift->reference->unregister_schema(@_);
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

