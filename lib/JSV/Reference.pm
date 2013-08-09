package JSV::Reference;

use strict;
use warnings;

use Carp;
use JSON::Pointer;
use URI;
use URI::Split qw(uri_split uri_join);

my %memo;

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        registered_schema_map => {},
        %$args,
    );

    bless $args => $class;
}

sub resolve {
    my ($self, $ref, $opts) = @_;

    %$opts = (
        base_uri => undef,
        root     => undef,
        %$opts,
    );

    return 0 unless (ref $ref eq 'HASH');
    return 0 unless (exists $ref->{'$ref'});

    my $ref_uri = URI->new($ref->{'$ref'});
    my ($normalize_uri, $fragment);

    if ($ref_uri->scheme) {
        return $self->get_schema($ref_uri);
    }
    else {
        if ( ( $ref_uri->path || $ref_uri->query ) && $opts->{base_uri} ) {
            return $self->get_schema($ref_uri->clone->abs($opts->{base_uri}));
        }
        elsif ( defined $ref_uri->fragment && defined $opts->{root} && ref $opts->{root} eq 'HASH' ) {
            eval {
                my $ref_obj = JSON::Pointer->get($opts->{root}, $ref_uri->fragment, 1);
                delete $ref->{'$ref'};
                %$ref = %$ref_obj;
            };
            if (my $e = $@) {
                undef $@;
                return 0;
            }
            return 1;
        }
        else {
            return 0;
        }
    }

}

sub get_schema {
    my ($self, $uri) = @_;
    my ($normalized_uri, $fragment) = $self->normalize_uri($uri);

    my $schema = $self->{registered_schema_map}{$normalized_uri};
    return unless ($schema);

    if (defined $fragment) {
        my $inner_schema;
        eval {
            $inner_schema = JSON::Pointer->get($schema, $fragment, 1);
        };
        if (my $e = $@) {
            undef $@;
            return;
        }
        return $inner_schema;
    }

    return $schema;
}

sub register_schema {
    my ($self, $uri, $schema) = @_;
    my $normalized_uri = $self->normalize_uri($uri);
    $self->{registered_schema_map}{$normalized_uri} = $schema;
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
