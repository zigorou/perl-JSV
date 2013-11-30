use strict;
use Test::More;


use JSV::Validator;

subtest "register_format" => sub {
    subtest "register from default" => sub {
        my $validator = JSV::Validator->new;
        $validator->register_format("hoge" => sub {
            $_[0] eq "hoge";
        });
        ok $validator->formats->{"hoge"};
    };
    subtest "register from zero" => sub {
        my $validator = JSV::Validator->new(formats => +{});
        $validator->register_format("hoge" => sub {
            $_[0] eq "hoge";
        });
        ok $validator->formats->{"hoge"};
        is keys %{ $validator->formats }, 1;
    };
};

done_testing;
