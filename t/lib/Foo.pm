package Foo;

use Moose;
BEGIN { extends qw( Bar ); }
use Test::More;

sub startup_foo1 : Startup( 1 ) { ok( 1 ); }

sub setup_foo1 : Setup {}

sub test_foo1 : Test( 2 ) { ok( 1 ) for 1 .. 2; }

sub teardown_foo1 : Teardown {}

sub shutdown_foo1 : Shutdown( 3 ) { ok( 1 ) for 1 .. 3; }

sub other_foo1 : Startup {}

1;
