package Test::JSV::Suite;

use strict;
use warnings;

use Carp;
use File::Basename;
use File::Spec;
use FindBin;
use JSON;
use Test::More;

sub run {
    my ($class, %opts) = @_;

    %opts = (
        base_dir                    => File::Spec->catdir(File::Spec->no_upwards(dirname(__FILE__), "../../../../t/suite/tests")),
        version                     => "",
        suite                       => "type",
        cb                          => sub {
            my ($schema, $instance, $expect) = @_;
            return 1;
        },
        verbose                     => 0,
        %opts
    );

    my $self = bless \%opts => $class;
    my $test_suite = $self->load_test_suite;

    for my $test_cases (@$test_suite) {
        $self->run_test_cases($test_cases);
    }

    done_testing;
}

sub run_test_cases {
    my ($self, $test_cases) = @_;

    my ($desc, $schema, $tests) = @$test_cases{qw/description schema tests/};

    subtest $desc => sub {
        for my $test_case (@$tests) {
            $self->run_test_case($schema, $test_case);
        }
    };
}

sub run_test_case {
    my ($self, $schema, $test_case) = @_;
    my ($desc, $data, $expect) = @$test_case{qw/description data valid/};

    is(
        $self->{cb}->($schema, $data, $expect),
        $expect ? 1 : 0,
        $desc,
    );
}

sub load_test_suite {
    my $self = shift;
    my $test_suite_file = File::Spec->catfile(
        $self->{version} ? ( $self->{base_dir}, $self->{version} ) : ( $self->{base_dir} ), 
        $self->{suite} . ".json"
    );

    note $test_suite_file;

    unless (-f $test_suite_file) {
        croak sprintf("Not exists test suite (base_dir: %s, version: %s, suite: %s)", @$self{qw/base_dir version suite/});
    }

    open(my $fh, "<", $test_suite_file) or croak $!;
    my $test_suite = decode_json(do { local $/; <$fh> });
    close $fh;
    return $test_suite;
}

1;
