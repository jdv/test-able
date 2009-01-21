package Baz;

use Moose;
BEGIN { extends qw( Foo ); }
use Test::More;

sub startup : Startup( 7 ) { ok( 1 ) for 1 .. 7; }

sub setup : Setup( 1 ) { ok( 1 ); }

sub test_9 { ok( 1 ) for 1 .. 9; }

sub teardown_2 { ok( 1 ) for 1 .. 2; }

sub shutdown : Shutdown( no_plan ) {}

sub other {}

1;
