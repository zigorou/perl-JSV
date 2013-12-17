use strict;
use warnings;

use File::Basename;
use Test::More;
use Test::JSV::Suite;
use JSV::Validator;

my $validator = JSV::Validator->new(enable_format => 1);

TODO : {
    local $TODO = "date-time format in this sample is not supported by JSV";
    subtest "strict type" => sub {
        Test::JSV::Suite->run(
            base_dir => dirname(__FILE__),
            suite    => "about",
            cb       => sub {
                my ($schema, $instance) = @_;
                return $validator->validate($schema, $instance);
            },
        );
    };
};

TODO : {
    local $TODO = "The numeric string will be valid and date-time format in this sample is not supported by JSV";
    subtest "loose type" => sub {
        Test::JSV::Suite->run(
            base_dir => dirname(__FILE__),
            suite   => "about",
            cb      => sub {
                my ($schema, $instance) = @_;
                return $validator->validate($schema, $instance, +{ loose_type => 1, });
            },
        );
    };
};

done_testing;


