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
            $context->log_error("The instance does not pass 'date-time' format check");
        }
    } elsif ($format eq 'uri') {
        unless (is_uri($instance)) {
            $context->log_error("The instance does not pass 'uri' format check");
        }
    } elsif ($format eq 'email') {
        # TODO: enable change to Email::Valid or Email::Valid::Loose
        unless (Email::Valid::Loose->address($instance)) {
            $context->log_error("The instance does not pass 'email' format check");
        }
    } elsif ($format eq 'ipv4') {
        unless (is_ipv4($instance)) {
            $context->log_error("The instance does not pass 'ipv4' format check");
        }
    } elsif ($format eq 'ipv6') {
        unless (is_ipv6($instance)) {
            $context->log_error("The instance does not pass 'ipv6' format check");
        }
    } elsif ($format eq 'hostname') {
        unless (is_domain($instance)) {
            $context->log_error("The instance does not pass 'hostname' format check");
        }
    } else {
        $context->log_error(sprintf("unknown format: format = %s", $format));
    }
}

1;
