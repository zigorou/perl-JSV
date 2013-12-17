requires 'perl', '5.008001';

requires 'B';
requires 'Carp';
requires 'Class::Accessor::Lite';
requires 'Clone';
requires 'Data::Walk';
requires 'Data::Validate::Domain';
requires 'Data::Validate::IP';
requires 'Data::Validate::URI';
requires 'Email::Valid::Loose';
requires 'Exporter';
requires 'File::Basename';
requires 'File::Spec';
requires 'FindBin';
requires 'Hash::MultiValue';
requires 'JSON';
requires 'JSON::Pointer';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Module::Pluggable::Object';
requires 'Path::Tiny';
requires 'Scalar::Util';
requires 'URI';
requires 'URI::Split';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

