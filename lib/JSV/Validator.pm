package JSV::Validator;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/json reference last_exception/]
);
use JSON;

use JSV::Keyword::Enum;
use JSV::Keyword::Ref;
use JSV::Keyword::Type;

use JSV::Keyword::MultipleOf;
use JSV::Keyword::Maximum;
use JSV::Keyword::Minimum;

use JSV::Keyword::MaxLength;
use JSV::Keyword::MinLength;
use JSV::Keyword::Pattern;

use JSV::Keyword::Items;
use JSV::Keyword::MaxItems;
use JSV::Keyword::MinItems;
use JSV::Keyword::UniqueItems;

use JSV::Keyword::MaxProperties;
use JSV::Keyword::MinProperties;
use JSV::Keyword::Required;
use JSV::Keyword::Properties;
use JSV::Keyword::Dependencies;

use JSV::Util::Type qw(detect_instance_type);

use JSV::Reference;

sub new {
    my $class = shift;
    bless {
        last_exception => undef,
        json           => JSON->new->allow_nonref,
        reference      => JSV::Reference->new,
    } => $class;
}

sub validate {
    my ($self, $schema, $instance, $opts) = @_;
    my $rv;
    $self->{last_exception} = undef;

    $opts ||= {};
    %$opts = (
        exists $opts->{type} ? () : (
            type => detect_instance_type($instance)
        ),
        exists $opts->{schema} ? () : (
            schema => $schema
        ),
        throw          => 0,
        pointer_tokens => [],
        %$opts,
    );

    eval {
        JSV::Keyword::Ref->validate($self, $schema, $instance, $opts);
        JSV::Keyword::Enum->validate($self, $schema, $instance, $opts);
        JSV::Keyword::Type->validate($self, $schema, $instance, $opts);

        if ($opts->{type} eq "integer" || $opts->{type} eq "number") {
            JSV::Keyword::MultipleOf->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Maximum->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Minimum->validate($self, $schema, $instance, $opts);
        }
        elsif ($opts->{type} eq "string") {
            JSV::Keyword::MaxLength->validate($self, $schema, $instance, $opts);
            JSV::Keyword::MinLength->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Pattern->validate($self, $schema, $instance, $opts);
        }
        elsif ($opts->{type} eq "array") {
            JSV::Keyword::Items->validate($self, $schema, $instance, $opts);
            JSV::Keyword::MaxItems->validate($self, $schema, $instance, $opts);
            JSV::Keyword::MinItems->validate($self, $schema, $instance, $opts);
            JSV::Keyword::UniqueItems->validate($self, $schema, $instance, $opts);
        }
        elsif ($opts->{type} eq "object") {
            JSV::Keyword::MaxProperties->validate($self, $schema, $instance, $opts);
            JSV::Keyword::MinProperties->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Required->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Properties->validate($self, $schema, $instance, $opts);
            JSV::Keyword::Dependencies->validate($self, $schema, $instance, $opts);
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

1;
