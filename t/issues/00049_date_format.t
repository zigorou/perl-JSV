BEGIN { $ENV{PERL_JSON_BACKEND} = 'JSON::XS' }
use strict;
use warnings;
use Test::More;
use Test::Requires qw(JSON::XS);
use JSV::Validator;

my $v      = JSV::Validator->new(environment => 'draft4');
my $schema = {
    type => 'string',
    format => 'date',
};

for ("2017-02-28", "2018-02-28", "2020-02-29") {
    is ($v->validate($schema, $_), 1, "valid: $_");
}

for ("I don't trust stairs. They're always up to something.", "2014-56-78", "2017-02-29", "2018-02-29", "2018-02-30", "2019-02-29") {
    is ($v->validate($schema, $_), 0, "invalid: $_");
}

done_testing;

1;
