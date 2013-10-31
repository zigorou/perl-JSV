requires 'perl', '5.008001';

requires 'B';
requires 'Carp';
requires 'Class::Accessor::Lite';
requires 'Clone';
requires 'Data::Walk';
requires 'Exporter';
requires 'JSON';
requires 'JSON::Pointer';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Module::Pluggable::Object';
requires 'Scalar::Util';
requires 'URI';
requires 'URI::Split';
requires 'File::Basename';
requires 'File::Spec';
requires 'FindBin';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

