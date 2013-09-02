use strict;
use warnings;

use JSV::Validator;
use Test::More;

my $s1 = +{
    id => "http://example.com/s1",
    definitions => {
        POSITIVE_INT => { type => "integer", minimum => 1 },
        SMALL_INT => { type => "integer", maximum => 65535 },
        SMALL_INT_AND_POSITIVE_INT => {
            "allOf" => [
                +{ '$ref' => "#/definitions/POSITIVE_INT" },
                +{ '$ref' => "#/definitions/SMALL_INT" },
            ]
        }
    }
};

my $s2 = +{
    oneOf => [
        +{ enum => [qw/none/] },
        +{ '$ref' => "http://example.com/s1#/definitions/SMALL_INT_AND_POSITIVE_INT" }
    ]
};

my $v = JSV::Validator->new( environment => "draft4" );
$v->reference->register_schema("http://example.com/s1" => $s1);

is($v->validate($s2, "none"), 1);
is($v->validate($s2, 0), 0);
is($v->validate($s2, "any"), 0);
is($v->validate($s2, 10), 1);

done_testing;
