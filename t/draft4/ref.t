use strict;
use warnings;

use Test::More;
use Test::JSV::Suite;
use JSON;
use JSV::Validator;

my $validator = JSV::Validator->new;

### TODO: Maybe commonize
open(my $fh, "<", "t/draft4/schema") or die $!;
my $core_schema = decode_json(do { local $/; <$fh> });
$validator->register_schema(
    $core_schema->{id},
    $core_schema,
);
close($fh);

subtest "strict type" => sub {
    Test::JSV::Suite->run(
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
        version => "draft4",
        suite   => "ref",
        cb      => sub {
            my ($schema, $instance) = @_;
            return $validator->validate($schema, $instance, +{ loose_type => 1 });
        },
    );
};

done_testing;
