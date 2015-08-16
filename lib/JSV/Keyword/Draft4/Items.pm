package JSV::Keyword::Draft4::Items;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSON;

use JSV::Keyword qw(:constants);
use JSV::Util::Type qw(detect_instance_type escape_json_pointer);

sub instance_type() { INSTANCE_TYPE_ARRAY(); }
sub keyword() { "items" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $items            = $class->keyword_value($schema);
    my $additional_items = $class->keyword_value($schema, "additionalItems");

    my $items_type = detect_instance_type($items);
    my $additional_items_type = detect_instance_type($additional_items);

    if ($items_type eq "object") { ### items as schema
        local $context->{current_schema_pointer} = $context->{current_schema_pointer} . "/" . $class->keyword;
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            local $context->{current_pointer} = $context->{current_pointer} . "/" . $i;
            $context->validate($items, $instance->[$i]);
        }
    }
    elsif ($items_type eq "array") { ### items as schema array
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            local $context->{current_pointer} = $context->{current_pointer} . "/" . $i;

            if (defined $items->[$i]) {
                local $context->{current_schema_pointer} =
                    $context->{current_schema_pointer} . "/" . $class->keyword . "/" . $i;
                $context->validate($items->[$i], $instance->[$i]);
            }
            elsif ($additional_items_type eq "object") {
                local $context->{current_schema_pointer} =
                    $context->{current_schema_pointer} . "/additionalItems";
                $context->validate($additional_items, $instance->[$i]);
            }
            elsif ($additional_items_type eq "boolean" && $additional_items == JSON::false) {
                $context->log_error("additionalItems are not allowed");
            }
         }
    }
    else { ### wrong schema
        $context->log_error("Wrong schema definition");
    }
}

1;
