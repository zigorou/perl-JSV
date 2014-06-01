use strict;
use warnings;

use JSV::Validator;
use Test::More;

my $hash1 = { a => 3, b => 4 };
my $hash2 = { a => 3, b => 4 };
my $hash3 = { a => 3, b => 4 };

my @keys1 = keys %$hash1;
my @keys2 = keys %$hash2;
my @keys3 = keys %$hash3;

# match order of keys
while ( "@keys1" ne "@keys2" ) {
  $hash2 = { a => 3, b => 4 };
  @keys2 = keys %$hash2;
}

# unmatch order of keys
while ( "@keys1" eq "@keys3" ) {
  $hash3 = { a => 3, b => 4 };
  @keys3 = keys %$hash3;
}

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

ok $v->validate($schema, { hoge => $hash2 });
ok $v->validate($schema, { hoge => $hash3 });

done_testing;
