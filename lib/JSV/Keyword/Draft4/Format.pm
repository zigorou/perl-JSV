package JSV::Keyword::Draft4::Format;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use Data::Validate::Domain qw(is_domain);
use Data::Validate::IP qw(is_ipv4 is_ipv6);
use Data::Validate::URI qw(is_uri);
use Email::Valid::Loose;
use JSV::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_STRING(); }
sub keyword() { "format" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $format = $class->keyword_value($schema);

    if ($format eq 'date-time') {
        # RFC3339
        unless ($instance =~ /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})/) {
            $context->log_error(sprintf("format isn`t date-time: %s", $instance));
        }
    } elsif ($format eq 'uri') {
        unless (is_uri($instance)) {
            $context->log_error(sprintf("format isn`t uri: %s", $instance));
        }
    } elsif ($format eq 'email') {
        # TODO: enable change to Email::Valid or Email::Valid::Loose
        unless (Email::Valid::Loose->address($instance)) {
            $context->log_error(sprintf("format isn`t email: %s", $instance));
        }
    } elsif ($format eq 'ipv4') {
        unless (is_ipv4($instance)) {
            $context->log_error(sprintf("format isn`t ipv4: %s", $instance));
        }
    } elsif ($format eq 'ipv6') {
        unless (is_ipv6($instance)) {
            $context->log_error(sprintf("format isn`t ipv6: %s", $instance));
        }
    } elsif ($format eq 'hostname') {
        unless (is_domain($instance)) {
            $context->log_error(sprintf("format isn`t hostname: %s", $instance));
        }
    } else {
        $context->log_error(sprintf("unknown format: format = %s, value = %s", $format, $instance));
    }
}

1;
