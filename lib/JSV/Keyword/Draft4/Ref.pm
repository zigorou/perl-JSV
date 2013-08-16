package JSV::Keyword::Draft4::Ref;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;
use JSV::Keyword qw(:constants);

sub instance_type { INSTANCE_TYPE_ANY(); }
sub keyword { '$ref' }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless ( $class->has_keyword($schema) );

    $opts ||= {};
    $class->initialize_args($schema, $instance, $opts);

    my $rv = $validator->reference->resolve(
        $schema,
        +{
            base_uri => $opts->{schema}{id} || undef,
            root     => $opts->{schema}
        }
    );

    return $rv;
}

1;
