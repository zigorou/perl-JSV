BEGIN { $ENV{PERL_JSON_BACKEND} = 'JSON::PP' };

use strict;
use warnings;
use Test::More;
use Test::Requires qw(JSON::PP);
use JSV::Validator;
use JSON qw//;

my @KEYS   = ('a'..'e');
my $v      = JSV::Validator->new(environment => 'draft4');
my $schema = {
    type => 'array',
    uniqueItems => 1
};

subtest 'check cannonical on PP' => sub {
    my $is_pp = JSON->is_pp;
    ok $is_pp, 'backend is pp';

    my $compare = { map { $_ => 1 } @KEYS };
    my $target  = { map { $_ => 1 } reverse @KEYS };
    is ($v->validate($schema, [$compare, $target]), 0, 'validated as uniqueItems');
};

done_testing;

1;
