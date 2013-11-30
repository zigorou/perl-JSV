use strict;
use warnings;

use Test::More;
use Test::Exception;

use JSV::Reference;

subtest "cannot resolve reference" => sub {
    my $reference = JSV::Reference->new;
    eval {
        $reference->resolve(+{ '$ref' => "http://example.schema.com/schema#fragment" }, +{});
    };
    note $@;
    ok $@;
};

done_testing;
