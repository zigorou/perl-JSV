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
        suite    => "basics",
        cb       => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance);
        },
    );
};

subtest "loose type" => sub {
    plan skip_all => "Test cases is not suitable with loose mode";
    Test::JSV::Suite->run(
        base_dir => dirname(__FILE__),
        suite   => "basics",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance, +{ loose_type => 1, });
        },
    );
};

done_testing;


