package JSV::Keyword::Draft4::Items;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use Carp;

use JSV::Keyword qw(:constants);
use JSV::Exception;
use JSV::Util::Type qw(detect_instance_type);

sub instance_type { INSTANCE_TYPE_ARRAY(); }
sub keyword { "items" }
sub keyword_priority { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;
    return 1 unless $class->has_keyword($schema);
    return 1 unless $context->current_type eq "array";

    my $items            = $class->keyword_value($schema);
    my $additional_items = $class->keyword_value($schema, "additionalItems");

    my $items_type = detect_instance_type($items);
    my $additional_items_type = detect_instance_type($additional_items);

    if ($items_type eq "object") { ### items as schema
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$context->pointer_tokens}, $i);

            $context->throw_error(1);
            eval {
                $context->validate($items, $instance->[$i]);
            };
            if (my $e = $@) {
                $context->throw_error(0);
                croak $e;
            }

            pop(@{$context->pointer_tokens});
        }
        return 1;
    }
    elsif ($items_type eq "array") { ### items as schema array
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$context->pointer_tokens}, $i);

            if (defined $items->[$i]) {
                $context->throw_error(1);
                eval {
                    $context->validate($items->[$i], $instance->[$i]);
                };
                if (my $e = $@) {
                    $context->throw_error(0);
                    croak $e;
                }
            }
            elsif ($additional_items_type eq "object") {
                eval {
                    $context->validate($additional_items, $instance->[$i]);
                };
                if (my $e = $@) {
                    $context->throw_error(0);
                    croak $e;
                }
            }
            elsif ($additional_items_type eq "boolean" && $additional_items == 0) {
                JSV::Exception->throw(
                    "The instance cannot have additional items",
                    $context,
                );
            }

            pop(@{$context->pointer_tokens});
         }
    }
    else { ### wrong schema
        JSV::Exception->throw(
            "Wrong schema definition",
            $context,
        );
    }
}

1;
