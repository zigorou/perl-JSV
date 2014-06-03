use strict;
use warnings;

use JSV::Validator;
use Test::More;
use JSON;

my $id = 'https://github.com/zigorou/perl-JSV';

my $schema = {
    id => $id,
    definitions => {
        MULTIPLE_OF => {
            description => "test definition to check multipleOf keyword",
            multipleOf  => 2,
            type        => "number"
        },
        MAXIMUM => {
            description => "test definition to check maximum keyword",
            maximum     => 1,
            type        => "number",
        },
        MINIMUM => {
            description => "test definition to check minimum keyword",
            minimum     => -1,
            type        => "number"
        },
        MAXIMUM_EXCLUSIVE => {
            description      => "test definition to check maximum and exclusiveMaximum keywords",
            maximum          => 1,
            exclusiveMaximum => JSON::true,
            type             => "number"
        },
        MINIMUM_EXCLUSIVE => {
            description      => "test definition to check minimum and exclusiveMinimum keywords",
            minimum          => -1,
            exclusiveMinimum => JSON::true,
            type             => "number"
        },
    },
};

my $v = JSV::Validator->new( environment => "draft4" );
$v->reference->register_schema($id => $schema);

subtest 'multipleOf with loose_type' => sub {
    is $v->validate({ '$ref' => "$id#/definitions/MULTIPLE_OF" }, '1',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MULTIPLE_OF" }, '2',   { loose_type => 1 } ), JSON::true,  'integer valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MULTIPLE_OF" }, '1.0', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MULTIPLE_OF" }, '2.1', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MULTIPLE_OF" }, '2.0', { loose_type => 1 } ), JSON::true,  'number valid case';
};

subtest 'maximum with loose_type' => sub {
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM" }, '1',   { loose_type => 1 } ), JSON::true,  'integer valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM" }, '2',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM" }, '1.0', { loose_type => 1 } ), JSON::true,  'number valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM" }, '1.1', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM" }, '2.0', { loose_type => 1 } ), JSON::false, 'number invalid case';
};

subtest 'minimum with loose_type' => sub {
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM" }, '-1',   { loose_type => 1 } ), JSON::true,  'integer valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM" }, '-2',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM" }, '-1.0', { loose_type => 1 } ), JSON::true,  'number valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM" }, '-1.1', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM" }, '-2.0', { loose_type => 1 } ), JSON::false, 'number invalid case';
};


subtest 'exclusiveMaximum with loose_type' => sub {
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '1',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '2',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '1.0', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '1.1', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '2.0', { loose_type => 1 } ), JSON::false, 'number invalid case';

    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '0',   { loose_type => 1 } ), JSON::true, 'integer valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MAXIMUM_EXCLUSIVE" }, '0.9', { loose_type => 1 } ), JSON::true, 'number valid case';
};

subtest 'exclusiveMinimum with loose_type' => sub {
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-1',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-2',   { loose_type => 1 } ), JSON::false, 'integer invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-1.0', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-1.1', { loose_type => 1 } ), JSON::false, 'number invalid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-2.0', { loose_type => 1 } ), JSON::false, 'number invalid case';

    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '0',    { loose_type => 1 } ), JSON::true, 'integer valid case';
    is $v->validate({ '$ref' => "$id#/definitions/MINIMUM_EXCLUSIVE" }, '-0.9', { loose_type => 1 } ), JSON::true, 'number valid case';
};

done_testing;
