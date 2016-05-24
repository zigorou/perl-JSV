use strict;
use warnings;

use Test::More;
use Test::Output;

my $exit;
sub jsv { 
    system($^X, 'script/jsv', @_); $exit = $? >> 8 
}

output_like { jsv '-h' } qr/^Usage:\n  jsv /m, qr/^$/, 'help';
is $exit, 0, 'no error';

output_is { jsv 't/script/file6.json' } 
    "", "failed to open t/script/file6.json\n";
is $exit, 3, 'missing file';

output_is { jsv 't/script/file5.json' } 
    "", "failed to parse t/script/file5.json\n";
is $exit, 2, 'JSON broken';

output_is { jsv '-s', 't/script/schema.json', map { "t/script/file$_.json" } 1..4 }
    "invalid t/script/file1.json\n".
    "valid   t/script/file2.json\n".
    "valid   t/script/file3.json\n".
    "invalid t/script/file4.json\n",
    "";
is $exit, 1, 'JSON invalid';

output_is { jsv '-s', 't/script/schema.json', 't/script/file2.json', '-q' } "", "";
is $exit, 0, 'JSON valid';

done_testing;
