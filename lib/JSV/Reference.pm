package JSV::Reference;

use strict;
use warnings;

use Carp;
use Clone qw(clone);
use Data::Walk;
use JSON::Pointer;
use Scalar::Util qw(weaken);
use URI;
use URI::Split qw(uri_split uri_join);

my %memo;

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        registered_schema_map => {},
        max_recursion         => 10,
        %$args,
    );

    bless $args => $class;
}

sub resolve {
    my ($self, $ref, $opts) = @_;
    die 'ref value should be hash' unless ref $ref eq 'HASH';
    die '$ref not found'           unless exists $ref->{'$ref'};

    my $ref_uri = URI->new($ref->{'$ref'});
    my $ref_obj = $self->get_schema($ref_uri, $opts);

    if ( ref $ref_obj eq 'HASH' && exists $ref_obj->{'$ref'} ) {
        $self->resolve($ref_obj, $opts);
    }

    ### TODO: Does this weaken have means?
    weaken($ref_obj);
    %$ref = %$ref_obj;

    $ref->{id} = $ref_uri->as_string;
}

sub get_schema {
    my ($self, $uri, $opts) = @_;
    if ( ! $uri->scheme && $opts->{base_uri} ) {
        $uri = $uri->abs($opts->{base_uri});
    }

    my ($normalized_uri, $fragment) = $self->normalize_uri($uri);
    my $schema = $self->{registered_schema_map}{$normalized_uri} || $opts->{root};

    if ( $fragment ) {
        eval {
            $schema = JSON::Pointer->get($schema, $fragment, 1);
        };
        if (my $e = $@) {
            die sprintf("cannot resolve reference: uri = %s, msg = %s", $uri, $e);
        }
    }

    unless (ref $schema eq 'HASH') {
        die sprintf("cannot resolve reference: uri = %s", $uri);
    }

    return $schema;
}

sub register_schema {
    my ($self, $uri, $schema) = @_;
    my $normalized_uri = $self->normalize_uri($uri);
    my $cloned_schema = clone($schema);

    ### recursive reference resolution
    walkdepth(+{
        wanted => sub {
            if (
                defined $Data::Walk::type &&
                $Data::Walk::type eq "HASH" &&
                exists $_->{'$ref'} &&
                !ref $_->{'$ref'} &&
                keys %$_ == 1
            ) {
                my $ref_uri = URI->new($_->{'$ref'});
                return if $ref_uri->scheme;
                $_->{'$ref'} = $ref_uri->abs($normalized_uri)->as_string;
            }
        },
    }, $cloned_schema);

    $self->{registered_schema_map}{$normalized_uri} = $cloned_schema;
}

sub unregister_schema {
    my ($self, $uri) = @_;
    my $normalized_uri = $self->normalize_uri($uri);
    delete $self->{registered_schema_map}{$normalized_uri};
}

sub normalize_uri {
    my ($self, $uri) = @_;
    my %parts;

    @parts{qw/scheme authority path query fragment/} = uri_split($uri);
    my $fragment = $parts{fragment};
    $parts{fragment} = undef;

    my $normalized_uri = uri_join(@parts{qw/scheme authority path query fragment/});

    return wantarray ? ($normalized_uri, $fragment) : $normalized_uri;
}

1;

__END__
