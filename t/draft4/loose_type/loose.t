use strict;
use warnings;

use File::Basename;
use Test::More;
use Test::JSV::Suite;
use JSV::Validator;

my $validator = JSV::Validator->new;

#TODO: {
#    local $TODO = "Strict mode doesn't allow type mismatch";
#
#    subtest "strict type (loose)" => sub {
#        Test::JSV::Suite->run(
#            base_dir => dirname(__FILE__),
#            suite   => "loose",
#            cb      => sub {
#                my ($schema, $instance) = @_;
#                return $validator->validate($schema, $instance);
#            },
#        );
#    };
#};

subtest "strict type" => sub {
    Test::JSV::Suite->run(
        base_dir => dirname(__FILE__),
        suite   => "strict",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance);
        },
    );
};

subtest "loose type" => sub {
    Test::JSV::Suite->run(
        base_dir => dirname(__FILE__),
        suite   => "loose",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance, +{ loose_type => 1 });
        },
    );
};

done_testing;
