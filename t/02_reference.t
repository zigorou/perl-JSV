use strict;
use warnings;

use Test::More;
use Test::Exception;

use JSV::Reference;

subtest "cannot resolve reference" => sub {
    my $reference = JSV::Reference->new;
    my $example_schema = {
        id => 'http://example.schema.com/schema',
        fragment => {
            type => 'object',
            properties => {
                foo => { type => 'integer' }, 
            }
        },
    };
    $reference->register_schema( $example_schema->{id}, $example_schema );
    
    subtest 'uri not found' => sub {
        local $@;
        my $ref = { '$ref' => 'http://notfound.schema.com/schema' };
        throws_ok {
            $reference->resolve($ref, +{});
        } qr/^cannot resolve reference/;
        note $@;
    };

    subtest 'uri found' => sub {
        local $@;
        my $ref = { '$ref' => 'http://example.schema.com/schema' };
        my $resolved = eval {
            $reference->resolve($ref, +{});
        };
        ok $resolved;
        is_deeply($ref, $example_schema);
    };

    subtest 'fragment not found' => sub {
        local $@;
        my $ref = { '$ref' => 'http://example.schema.com/schema#/bad_fragment' };
        throws_ok {
            $reference->resolve($ref, +{});
        } qr/^cannot resolve reference fragment/;
        note $@;
    };

    subtest 'fragment found' => sub {
        local $@;
        my $ref = { '$ref' => 'http://example.schema.com/schema#/fragment' };
        my $resolved = eval {
            $reference->resolve( $ref , +{});
        };
        ok $resolved;
        is_deeply(
            $ref,
            +{
                %{ $example_schema->{fragment} },
                id => 'http://example.schema.com/schema#/fragment',
            }
        ) or note explain $ref;
    };
};

done_testing;
