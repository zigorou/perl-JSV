use strict;
use warnings;
use Test::JSV::Suite;
use JSV::Validator;

my $validator = JSV::Validator->new;
Test::JSV::Suite->run(
    version => "draft4",
    suite   => "maxItems",
    cb      => sub {
        my ($schema, $instance) = @_;
        return $validator->validate($schema, $instance);
    },
);
