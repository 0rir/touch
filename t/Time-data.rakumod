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
        {   given => $max,
            instant => Instant.from-posix($max),
            expected => Instant.from-posix($max),
            sec => $max, nsec => 0, posix => $max,
        },
        {   given => -21.222_222_222,
            instant => Instant.from-posix(-21.222_222_222),
            expected => Instant.from-posix(-21.222_222_222),
            sec => -22, nsec => 777_777_778, posix => -21.222_222_222,
        },
        {   given => -10.000_000_001,
            instant => Instant.from-posix(-10.000_000_001),
            expected => Instant.from-posix(-10.000_000_001),
            sec => -11, nsec => 999_999_999, posix => -10.000_000_001
        },
        {   given => -0.4,
            instant => Instant.from-posix(-0.4),
            expected => Instant.from-posix(-0.4),
            sec => -1, nsec => 6 * 10⁸, posix => -0.4
        },

        {   given => 0,
            instant => Instant.from-posix(0),
            expected => Instant.from-posix(0),
            sec => 0, nsec => 0, posix => 0,
        },
        {   given => 5.999,
            instant => Instant.from-posix(5.999),
            expected => Instant.from-posix(5.999),
            sec => 5, nsec => 999000000, posix => 5.999
        },
        {   given => 10.000_000_001,
            instant => Instant.from-posix(10.000_000_001),
            expected => Instant.from-posix(10.000_000_001),
            sec => 10, nsec => 1, posix => 10.000_000_001
        },
        {    given => 40.000_000_000_9,
            instant => Instant.from-posix(40.000_000_000_9),
            expected => Instant.from-posix(40.000_000_000_9),
            sec => 40, nsec => 0, posix => 40.000_000_000_9
        },
        {   given => 117.444_44,
            instant => Instant.from-posix(117.44444),
            expected => Instant.from-posix(117.44444),
            sec => 117, nsec => 444_440_000, posix => 117.44444
        },
        {   given => 200.000_000_06,
            instant => Instant.from-posix(200.000_000_06),
            expected => Instant.from-posix(200.000_000_06),
            sec => 200, nsec => 60, posix => 200.000_000_06
        },
        ;

