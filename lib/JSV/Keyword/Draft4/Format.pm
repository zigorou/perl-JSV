package JSV::Keyword::Draft4::Format;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use Data::Validate::Domain qw(is_domain);
use Data::Validate::IP qw(is_ipv4 is_ipv6);
use Data::Validate::URI qw(is_uri);
use Email::Valid::Loose;
use JSV::Keyword qw(:constants);
use JSV::Exception;

sub instance_type { INSTANCE_TYPE_STRING(); }
sub keyword { "format" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless ( $class->has_keyword($schema) );

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "string") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    if ($keyword_value eq 'date-time') {
        # RFC3339
        unless ($instance =~ /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})/) {
            JSV::Exception->throw("format isn`t date-time", $opts);
        }
    } elsif ($keyword_value eq 'uri') {
        unless (is_uri($instance)) {
            JSV::Exception->throw("format isn`t uri", $opts);
        }

    } elsif ($keyword_value eq 'email') {
        # TODO: enable change to Email::Valid or Email::Valid::Loose
        unless (Email::Valid::Loose->address($instance)) {
            JSV::Exception->throw("format isn`t email", $opts);
        }
    } elsif ($keyword_value eq 'ipv4') {
        unless (is_ipv4($instance)) {
            JSV::Exception->throw("format isn`t ipv4", $opts);
        }
    } elsif ($keyword_value eq 'ipv6') {
        unless (is_ipv6($instance)) {
            JSV::Exception->throw("format isn`t ipv6", $opts);
        }
    } elsif ($keyword_value eq 'hostname') {
        unless (is_domain($instance)) {
            JSV::Exception->throw("format isn`t hostname", $opts);
        }
    } else {
        JSV::Exception->throw("disable format", $opts);
    }

    return 1;
}
