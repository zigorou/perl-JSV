use strict;
use warnings;
use lib "t/lib";
use Test::JSV::Suite;
use JSON;
use JSV::Validator;
use JSV::Keyword::Type;

my $validator = JSV::Validator->new;

### TODO: Maybe commonize
open(my $fh, "<", "t/draft4/schema") or die $!;
my $core_schema = decode_json(do { local $/; <$fh> });
$validator->reference->register_schema(
    $core_schema->{id},
    $core_schema,
);
close($fh);

Test::JSV::Suite->run(
    version => "draft4",
    suite   => "ref",
    cb      => sub {
        my ($schema, $instance) = @_;
        return $validator->validate($schema, $instance);
    },
);
