requires 'perl', '5.008001';

requires 'B';
requires 'Carp';
requires 'Class::Accessor::Lite';
requires 'Data::Clone';
requires 'Exporter';
requires 'JSON';
requires 'JSON::Pointer';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Scalar::Util';
requires 'URI';
requires 'URI::Split';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

