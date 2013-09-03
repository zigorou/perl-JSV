package JSV::Keyword::Draft4::Pattern;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_STRING(); }
sub keyword { "pattern" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "string") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    if ($instance =~ m/$keyword_value/) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance doesn't match the pattern value",
            $opts,
        );
    }
}

1;
