package Role1;

use Test::Able::Role;

with qw( Role2 );

setup role1_setup_1 => sub {};

test role1_test_1 => sub {};

1;
