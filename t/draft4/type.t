use strict;
use warnings;
use lib "t/lib";
use Test::JSV::Suite;
use JSV::Keyword::Type;

Test::JSV::Suite->run(
    version => "draft4",
    suite   => "type",
    cb      => sub {
        my ($schema, $instance) = @_;
        return JSV::Keyword::Type->validate($schema, $instance);
    },
);


