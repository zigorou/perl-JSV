use strict;
use warnings;
use lib "t/lib";
use Test::JSV::Suite;
use JSV::Validator;

my $validator = JSV::Validator->new;
Test::JSV::Suite->run(
    version => "draft4",
    suite   => "maxProperties",
    cb      => sub {
        my ($schema, $instance) = @_;
        return $validator->validate($schema, $instance);
    },
);
