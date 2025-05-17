use v6.c;
# vim: ft=raku expandtab sw=4
unit module Time-data;
use NativeCall;
use Test;

my Rat $machine-takes = 0.01;   # seconds to touch then get stat back

our $TESTLAG is export = %*ENV<TESTLAG> // $machine-takes;

our constant $file is export
        = $?FILE.IO.cleanup.parent(2).add('resources/testfile').path;

my $min = -10⁹;     # dupe magic
my $max = 10¹⁰;     # dupe magic


our @test is export =
        {   given => $min,
            instant => Instant.from-posix($min),
            expected => Instant.from-posix($min),
            sec => $min, nsec => 0, posix => $min,
        },
        {   given => 0,
            instant => Instant.from-posix(0),
            expected => Instant.from-posix(0),
            sec => 0, nsec => 0, posix => 0,
        },
        {
            given => $max -37,
            instant => Instant.from-posix($max),
            expected => Instant.from-posix($max),
            sec => $max, nsec => 0, posix => $max,
        },
        {   given => -10.000_000_001,
            instant => Instant.from-posix(-10.000_000_001),
            expected => Instant.from-posix(-10.000_000_001),
            sec => -11, nsec => 999_999_999, posix => -10.000_000_001
        },
        {   given => 10.000_000_001,
            instant => Instant.from-posix(10.000_000_001),
            expected => Instant.from-posix(10.000_000_001),
            sec => 10, nsec => 1, posix => 10.000_000_001
        },
;
