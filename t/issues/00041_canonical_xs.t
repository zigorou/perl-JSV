BEGIN { $ENV{PERL_JSON_BACKEND} = 'JSON::XS' }

use strict;
use warnings;
use Test::More;
use JSV::Validator;
use Test::Requires qw(JSON::XS);
use JSON qw//;

my @KEYS   = 'a'..'e';
my $v      = JSV::Validator->new(environment => 'draft4');
my $schema = {
    type => 'array',
    uniqueItems => 1
};

subtest 'check cannonical on XS' => sub {
    my $is_xs = JSON->is_xs;
    ok $is_xs, 'backend is xs';

    my $compare = { map { $_ => 1 } @KEYS };
    my $target  = { map { $_ => 1 } reverse keys %$compare };
    is ($v->validate($schema, [$compare, $target]), 0, 'validated as uniqueItems');
};

done_testing;

1;
