package JSV::Keyword::Draft4::Format;

use strict;
use warnings;
use parent qw(JSV::Keyword);

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
        # RFC3986
        my $regex = qr/
        \A
        (
            [a-z][a-z0-9+\-.]*:
            (
                \/\/
                ([a-z0-9\-._~%!\$&'()*+,;=]+@)?
                ([a-z0-9\-._~%]+
                |\[[a-f0-9:.]+\]
                |\[v[a-f0-9][a-z0-9\-._~%!\$&'()*+,;=:]+\])
                (:[0-9]+)?
                (\/[a-z0-9\-._~%!\$&'()*+,;=:@]+)*\/? # パス
            |
                (\/?[a-z0-9\-._~%!\$&'()*+,;=:@]+(\/[a-z0-9\-._~%!\$&'()*+,;=:@]+)*\/?)?
            )
        |
            (
                [a-z0-9\-._~%!\$&'()*+,;=@]+(\/[a-z0-9\-._~%!\$&'()*+,;=:@]+)*\/?
            |
                (\/[a-z0-9\-._~%!\$&'()*+,;=:@]+)+\/?
            )
        )
        (\?[a-z0-9\-._~%!\$&'()*+,;=:@\/?]*)?
        (\#[a-z0-9\-._~%!\$&'()*+,;=:@\/?]*)?
        \Z
        /x;

        unless ($instance =~ /$regex/) {
            JSV::Exception->throw("format isn`t uri", $opts);
        }

    } elsif ($keyword_value eq 'email') {
        unless ($instance =~ /\A[A-Z0-9+_.-]+@[A-Z0-9+_.-]+\Z/i) {
            JSV::Exception->throw("format isn`t email", $opts);
        }
    } elsif ($keyword_value eq 'ipv4') {
        unless ($instance =~ /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/) {
            JSV::Exception->throw("format isn`t ipv4", $opts);
        }
    } elsif ($keyword_value eq 'ipv6') {
        my $regex = qr/\A(((?=(?>.*?::)(?!.*::)))(::)?([0-9A-F]{1,4}::?){0,5}|([0-9A-F]{1,4}:){6})(\2([0-9A-F]{1,4}(::?|$)){0,2}|((25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])(\.|$)){4}|[0-9A-F]{1,4}:[0-9A-F]{1,4})(?<![^:]:)(?<!\.)\z/i;
        unless ($instance =~ /$regex/) {
            JSV::Exception->throw("format isn`t ipv6", $opts);
        }
    } elsif ($keyword_value eq 'hostname') {
        unless ($instance =~ /\A((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}\Z/) {
            JSV::Exception->throw("format isn`t hostname", $opts);
        }
    } else {
        JSV::Exception->throw("disable format", $opts);
    }

    return 1;
}
