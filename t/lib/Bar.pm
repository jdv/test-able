package Bar;

use Moose;
BEGIN { extends( 'Test::Able' ); }
use Test::More;

sub startup : Startup( 1 ) { ok( 1 ); }
sub startup_bar2 : Startup {}
sub startup_2_bar3 { ok( 1 ) for 1 .. 2; }
sub startup_bar4 {}

sub setup_bar1 : Setup {}
sub setup : Setup( 3 ) { ok( 1 ) for 1 .. 3; }
sub setup_bar3 {}
sub setup_11_bar4 { ok( 1 ) for 1 .. 11; }

sub test_bar1 : Test( 3 ) { ok( 1 ) for 1 .. 3; }
sub test_bar2 : Test {}
sub test_4 { ok( 1 ) for 1 .. 4; }
sub test_bar4 {}

sub teardown_bar1 : Teardown( 1 ) { ok( 1 ); }
sub teardown_bar2 : Teardown {}
sub teardown_6_bar3 { ok( 1 ) for 1 .. 6; }
sub teardown_0 {}

sub shutdown : Shutdown {}
sub shutdown_bar2 : Shutdown( 5 ) { ok( 1 ) for 1 .. 5; }
sub shutdown_bar3 {}
sub shutdown_15_bar4 { ok( 1 ) for 1 .. 15; }

sub other_bar1 {}
sub other {}

1;
