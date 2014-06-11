use strict;
use warnings;

use JSV::Validator;
use Test::More;

sub generate_deep_hash {
    my $n = shift;

    return +{ leaf1 => 3, leaf2 => 5 } if $n == 1;
    return +{ node1 => generate_deep_hash($n-1), node2 => generate_deep_hash($n-1) };
}

my $hash1 = generate_deep_hash(10);
my $hash2 = generate_deep_hash(10);

my $schema = +{
    type => "object",
    properties => {
        hoge => {
            "enum" => [
                $hash1,
            ],
        },
    }
};

my $v = JSV::Validator->new( environment => "draft4" );

# fail in probability (1 - 2^10) without deep_eq in enum validation
ok $v->validate($schema, { hoge => $hash2 });

done_testing;
