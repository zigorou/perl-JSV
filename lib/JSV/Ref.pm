package JSV::Ref;

use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/resolver ref_map/],
);
use JSON::Pointer;
use URI;
use URI::Escape qw(uri_unescape);

sub new {
}

sub resolve_reference {
    my ($self, $self_schema, $ref_value) = @_;

    if (index($ref_value, "#") == 0) {
        my $pointer = uri_unescape(substr($ref_value, 1));
        JSON::Pointer->get($self_schema, $pointer);
    }
    else {
        my $uri = URI->new($ref_value);
        my $uri_without_fragment = $uri->clone;
        $uri_without_fragment->fragment("");

        unless (exists $self->{ref_map}{$uri_without_fragment->as_string}) {
            $self->{ref_map}{$uri_without_fragment->as_string} = $self->{resolver}->get(
                $uri_without_fragment->as_string
            );
        }

        return JSON::Pointer->get($self->{ref_map}{$uri_without_fragment->as_string}, $uri->fragment);
    }
}

1;
