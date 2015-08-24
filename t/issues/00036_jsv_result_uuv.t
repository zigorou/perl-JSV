use strict;
use warnings;

use Test::More;
use Test::Exception;
use JSV::Result;

lives_ok sub {
    my $result = JSV::Result->new;

    is($result->error, "", "initialized error");
    is_deeply($result->errors, [], "initialized errors");

    $result->get_error_map;
} => "JSV::Result->get_error_map does not raise UUV";

done_testing;
