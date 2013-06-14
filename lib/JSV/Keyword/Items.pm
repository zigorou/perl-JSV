package JSV::Keyword::Items;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use Carp;
use Data::Clone;

use JSV::Exception;
use JSV::Util::Type qw(detect_instance_type);

sub keyword { "items" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "array") {
        return 1;
    }

    my $items            = $class->keyword_value($schema);
    my $additional_items = $class->keyword_value($schema, "additionalItems");

    my $items_type = detect_instance_type($items);
    my $additional_items_type = detect_instance_type($additional_items);

    if ($items_type eq "object") { ### items as schema
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$opts->{pointer_tokens}}, $i);

            my $orig_type = $opts->{type};

            $opts->{type}  = detect_instance_type($instance->[$i]);
            $opts->{throw} = 1;

            eval {
                $validator->validate($items, $instance->[$i], $opts);
            };
            if (my $e = $@) {
                $opts->{throw} = 0;
                croak $e;
            }

            pop(@{$opts->{pointer_tokens}});

            $opts->{type} = $orig_type;
        }
        return 1;
    }
    elsif ($items_type eq "array") { ### items as schema array
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$opts->{pointer_tokens}}, $i);

            my $orig_type = $opts->{type};

            $opts->{type}  = detect_instance_type($instance->[$i]);
            $opts->{throw} = 1;

            if (defined $items->[$i]) {
                eval {
                    $validator->validate($items->[$i], $instance->[$i], $opts);
                };
                if (my $e = $@) {
                    $opts->{throw} = 0;
                    croak $e;
                }
            }
            elsif ($additional_items_type eq "object") {
                eval {
                    $validator->validate($additional_items, $instance->[$i], $opts);
                };
                if (my $e = $@) {
                    $opts->{throw} = 0;
                    croak $e;
                }
            }
            elsif ($additional_items_type eq "boolean" && $additional_items == 0) {
                $opts->{throw} = 0;
                JSV::Exception->throw(
                    "The instance cannot have additional items",
                    $opts,
                );
            }

            pop(@{$opts->{pointer_tokens}});

            $opts->{type} = $orig_type;
         }
    }
    else { ### wrong schema
        JSV::Exception->throw(
            "Wrong schema definition",
            $opts,
        );
    }
}

1;
