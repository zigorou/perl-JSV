use strict;
use warnings;

use Carp;
use Cwd qw(realpath);
use File::Basename;
use File::Find;
use File::Spec;
use JSON;
use Test::More;
use Test::JSV::Suite;
use JSV::Validator;
use URI;

use File::Spec;
use File::Basename;

my $validator = JSV::Validator->new;

my $base_dir = File::Spec->catdir(dirname(__FILE__), "../../suite/remotes");
find(
    +{
        wanted => sub {
            return unless -f;
            return unless m/\.json$/;

            my $schema_file = $_;
            open(my $fh, "<", $schema_file);
            my $schema = decode_json(do { local $/; <$fh> });
            close $fh;

            my $rel_path = File::Spec->abs2rel($schema_file, $base_dir);
            my $uri = URI->new_abs($rel_path, "http://localhost:1234/");

            $validator->register_schema(
                $uri->as_string, $schema,
            );
        },
        no_chdir => 1,
    },
    $base_dir,
);

TODO: {
    local $TODO = "Currently, JSV cannot understand 'id' field";

    subtest "strict type" => sub {
        Test::JSV::Suite->run(
            base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
            version => "draft4",
            suite   => "refRemote",
            cb      => sub {
                my ($schema, $instance) = @_;
                return $validator->validate($schema, $instance);
            },
        );
    };

    subtest "loose type" => sub {
        Test::JSV::Suite->run(
            base_dir => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../suite/tests")),
            version => "draft4",
            suite   => "refRemote",
            cb      => sub {
                my ($schema, $instance) = @_;
                return $validator->validate($schema, $instance, +{ loose_type => 1 });
            },
        );
    };
}
;


done_testing;
