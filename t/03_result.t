use strict;
use warnings;

use Test::More;

use JSV::Result;

subtest "to_boolean" => sub {
    subtest "has multiple errors" => sub {
        my $result = JSV::Result->new(errors => [1]);
        is $result->to_boolean, 0;
    };
    subtest "has single error" => sub {
        my $result = JSV::Result->new(error => +{});
        is $result->to_boolean, 0;
    };
    subtest "has no errors" => sub {
        my $result = JSV::Result->new(errors => []);
        is $result->to_boolean, 1;
    };
};

subtest "equals" => sub {
    subtest "equals to 0" => sub {
        my $result = JSV::Result->new(errors => [1]);
        ok $result->equals(0);
    };
    subtest "equals to 1" => sub {
        my $result = JSV::Result->new(errors => []);
        ok $result->equals(1);
    };
};

subtest "get_error" => sub {
    subtest "get single error" => sub {
        my $result = JSV::Result->new(error => +{ foo => 1 });
        is_deeply $result->get_error, +{ foo => 1 };
    };

    subtest "get multiple errors" => sub {
        my $errors = [+{ foo => 1 }, +{ bar => 2 }];
        my $result = JSV::Result->new(errors => $errors);
        is_deeply [$result->get_error], $errors;
    };

    subtest "get multiple errors, with pointer" => sub {
        my $errors = [+{ pointer => "/foo" }, +{ pointer => "/bar" }];
        my $result = JSV::Result->new(errors => $errors);
        is_deeply [$result->get_error("/bar")], [+{ pointer => "/bar" }];
    };
};


done_testing;
