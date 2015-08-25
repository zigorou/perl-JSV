use strict;
use warnings;

use Test::More;
use Test::Exception;

use JSV::Reference;

my $reference = JSV::Reference->new;
my $example_schema = {
    id => 'http://example.schema.com/schema.json',
    fragment => {
        type => 'object',
        properties => {
            foo => { type => 'integer' }, 
        }
    },
};
$reference->register_schema( $example_schema->{id}, $example_schema );

subtest "can resolve reference" => sub {
    subtest 'fragment found' => sub {
        my $ref = { '$ref' => 'http://example.schema.com/schema.json#/fragment' };
        my $resolved = eval {
            $reference->resolve( $ref , +{});
        };
        ok $resolved;
        is_deeply(
            $ref,
            +{
                %{ $example_schema->{fragment} },
                id => 'http://example.schema.com/schema.json#/fragment',
            }
        ) or note explain $ref;
    };

    subtest 'relative reference found (parent)' => sub {
        my $ref = { '$ref' => '../schema.json#/fragment' };
        my $resolved = eval {
            $reference->resolve( $ref , +{ base_uri => "http://example.schema.com/another/schema.json" });
        };
        ok $resolved;
        is_deeply(
            $ref,
            +{
                %{ $example_schema->{fragment} },
                id => 'http://example.schema.com/schema.json#/fragment',
            }
        ) or note explain $ref;
    };

    subtest 'relative reference found (current)' => sub {
        my $ref = { '$ref' => './schema.json#/fragment' };
        my $resolved = eval {
            $reference->resolve( $ref , +{ base_uri => "http://example.schema.com/another_schema.json" });
        };
        ok $resolved;
        is_deeply(
            $ref,
            +{
                %{ $example_schema->{fragment} },
                id => 'http://example.schema.com/schema.json#/fragment',
            }
        ) or note explain $ref;
    };
};

subtest "cannot resolve reference" => sub {
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
        my $ref = { '$ref' => 'http://example.schema.com/schema.json' };
        my $resolved = eval {
            $reference->resolve($ref, +{});
        };
        ok $resolved;
        is_deeply($ref, $example_schema);
    };

    subtest 'fragment not found' => sub {
        local $@;
        my $ref = { '$ref' => 'http://example.schema.com/schema.json#/bad_fragment' };
        throws_ok {
            $reference->resolve($ref, +{});
        } qr/^cannot resolve reference fragment/;
        note $@;
    };
};

done_testing;
