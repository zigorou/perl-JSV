use strict;
use warnings;

use Test::More;

use JSV::Validator;
use JSV::Result;

subtest "keywords that have subschema" => sub {
    subtest "allOf" => sub {
        my $s0 = +{
            allOf => [
                { type => "string" },
                { type => "object" }
            ]
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, "foobar");
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/allOf/1";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "anyOf" => sub {
        my $s0 = +{
            anyOf => [
                { type => "object" }
            ]
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, "foo");
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/anyOf/0";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "dependencies (property)" => sub {
        my $s0 = +{
            dependencies => {
                "foo" => ["bar"]
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, +{ "foo" => 1 });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/dependencies/foo";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "dependencies (schema)" => sub {
        my $s0 = +{
            dependencies => {
                "foo" => {
                    required => ["bar"]
                }
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, +{ "foo" => 1 });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/dependencies/foo";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "items (schema)" => sub {
        my $s0 = +{
            items => {
               type => "object"
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, ["foo"]);
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/items";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "items (array)" => sub {
        my $s0 = +{
            items => [
                { type => "string" },
                { type => "object" }
            ]
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, ["foo", 123]);
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/items/1";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "additionalItems" => sub {
        my $s0 = +{
            items => [
                { type => "string" },
            ],
            additionalItems => {
                type => "object"
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, ["foo", 123]);
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/additionalItems";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "oneOf" => sub {
        my $s0 = +{
            oneOf => [
                { type => "object" }
            ]
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, "foo");
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/oneOf/0";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "properties" => sub {
        my $s0 = +{
            properties => {
                foo => {
                    type => "object"
                }
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, +{ "foo" => 123 });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/properties/foo";
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "patternProperties" => sub {
        my $s0 = +{
            patternProperties => {
                '^f.*$' => {
                    type => "object"
                }
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, +{ "foo" => 123 });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, '/patternProperties/^f.*$';
        is_deeply $error->{schema_pointer_history}, [];
    };

    subtest "additionalProperties" => sub {
        my $s0 = +{
            properties => {
                foo => {
                    type => "number",
                }
            },
            additionalProperties => {
                type => "object",
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        my $res = $v->validate($s0, +{ "foo" => 123, "bar" => "quux" });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "/additionalProperties";
        is_deeply $error->{schema_pointer_history}, [];
    };
};

subtest 'with $ref' => sub {
    subtest 'nested $ref' => sub {
        my $s0 = +{
            properties => {
                person => {
                    '$ref' => "http://example.com/s1#/definitions/person"
                }
            }
        };

        my $s1 = +{
            id => "http://example.com/s1",
            definitions => {
                person => {
                    properties => {
                        name => { '$ref' => "http://example.com/s2#/definitions/name" }
                    }
                }
            }
        };

        my $s2 = +{
            id => "http://example.com/s2",
            definitions => {
                name =>  { type => "string" },
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );
        $v->reference->register_schema("http://example.com/s1" => $s1);
        $v->reference->register_schema("http://example.com/s2" => $s2);

        my $res = $v->validate($s0, +{ person => { name => [] } });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "http://example.com/s2#/definitions/name";
        is_deeply $error->{schema_pointer_history}, [
            "/properties/person",
            "http://example.com/s1#/definitions/person/properties/name",
        ];
    };

    subtest 'self referencing $ref' => sub {
        my $s0 = +{
            definitions => {
                person => {
                    properties => {
                        name => { '$ref' => "#/definitions/name" }
                    }
                },
                name => {
                    type => "string"
                }
            },
            properties => {
                person => {
                    '$ref' => "#/definitions/person"
                }
            }
        };

        my $v = JSV::Validator->new( environment => "draft4" );

        my $res = $v->validate($s0, +{ person => { name => [] } });
        my ($error) = $res->get_error;

        is $error->{schema_pointer}, "#/definitions/name";
        is_deeply $error->{schema_pointer_history}, [
            "/properties/person",
            "#/definitions/person/properties/name",
        ];
    };
};

done_testing;
