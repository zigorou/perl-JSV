use strict;
use warnings;

use Test::More;
use Test::Exception;

use JSV::Reference;

subtest "cannot resolve reference" => sub {
    my $reference = JSV::Reference->new;
    dies_ok {
        $reference->resolve(+{ '$ref' => "http://example.schema.com/schema#fragment" });
    };
};

done_testing;
