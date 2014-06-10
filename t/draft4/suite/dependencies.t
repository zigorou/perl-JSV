use strict;
use warnings;

use Test::More;
use Test::JSV::Suite;
use JSV::Validator;

use File::Spec;
use File::Basename;

subtest "strict mode" => sub {
    my $validator = JSV::Validator->new;
    Test::JSV::Suite->run(
        base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
        version => "draft4",
        suite   => "dependencies",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance);
        },
    );
};

subtest "loose mode" => sub {
    my $validator = JSV::Validator->new;
    Test::JSV::Suite->run(
        base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
        version => "draft4",
        suite   => "dependencies",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance, +{ loose_type => 1 });
        },
    );
};

done_testing;
