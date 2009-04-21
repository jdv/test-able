package Class1;

use Test::Able;

with qw( Role1 );

startup  class1_startup_1 => sub {};

test class1_test_1 => sub {};

shutdown class1_shutdown_1 => sub {};

1;
