use strict;
use Test::More;


use JSV::Validator;

subtest "register_format" => sub {
    subtest "register from default" => sub {
        my $validator = JSV::Validator->new;
        $validator->register_format("hoge" => sub {
            $_[0] eq "hoge";
        });
        ok $validator->format_support->{"hoge"};
    };
    subtest "register from zero" => sub {
        my $validator = JSV::Validator->new(format_support => +{});
        $validator->register_format("hoge" => sub {
            $_[0] eq "hoge";
        });
        ok $validator->format_support->{"hoge"};
        is keys %{ $validator->format_support }, 1;
    };
};

done_testing;
