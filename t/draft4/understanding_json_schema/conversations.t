use strict;
use warnings;

use File::Basename;
use Test::More;
use Test::JSV::Suite;
use JSV::Validator;

my $validator = JSV::Validator->new;

subtest "strict type" => sub {
    Test::JSV::Suite->run(
        base_dir => dirname(__FILE__),
        suite    => "conversations",
        cb       => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance);
        },
    );
};

TODO: {
    local $TODO = "numeric string will be valid";
    subtest "loose type" => sub {
        Test::JSV::Suite->run(
            base_dir => dirname(__FILE__),
            suite   => "conversations",
            cb      => sub {
                my ($schema, $instance) = @_;
                return $validator->validate($schema, $instance, +{ loose_type => 1, });
            },
        );
    };
};

done_testing;


