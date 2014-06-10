use strict;
use warnings;

use Test::More;
use Test::JSV::Suite;
use JSON;
use JSV::Validator;

use File::Spec;
use File::Basename;

my $validator = JSV::Validator->new;

### TODO: Maybe commonize
open(my $fh, "<", "t/draft4/suite/schema") or die $!;
my $core_schema = decode_json(do { local $/; <$fh> });
$validator->register_schema(
    $core_schema->{id},
    $core_schema,
);
close($fh);

subtest "strict type" => sub {
    Test::JSV::Suite->run(
        base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
        version => "draft4",
        suite   => "ref",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance);
        },
    );
};

subtest "loose type" => sub {
    Test::JSV::Suite->run(
        base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
        version => "draft4",
        suite   => "ref",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance, +{ loose_type => 1 });
        },
    );
};

done_testing;
