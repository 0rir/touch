use v6.c;
# vim: ft=raku expandtab sw=4
unit module Time-data;
use NativeCall;
use Test;

my Rat $machine-takes = 0.01;
# seconds to touch then get stat back
our $LAG is export = %*ENV<LAG> // $machine-takes;

our constant $file is export
= $?FILE.IO.parent(2).add('resources/testfile').path;

my $min = -10⁹;
# from Touch
my $max = 10¹⁰;

our @test is export =
        {
            given => $min,
            instant => Instant.from-posix($min),
            expected => Instant.from-posix($min),
            sec => $min, nsec => 0, posix => $min,
        },
        {
            given => $max,
            instant => Instant.from-posix($max),
            expected => Instant.from-posix($max),
            sec => $max, nsec => 0, posix => $max,
        },
        {
            given => -107.4,
            instant => Instant.from-posix(-107.4),
            expected => Instant.from-posix(-107.4),
            sec => -108, nsec => 600000000, posix => -107.4
        },
        {
            given => -10² - 2,
            instant => Instant.from-posix(-10² - 2),
            expected => Instant.from-posix(-10² - 2),
            sec => -102, nsec => 0, posix => -10² - 2
        },
        {
            given => -500.1111,
            instant => Instant.from-posix(-500.1111),
            expected => Instant.from-posix(-500.1111),
            sec => -501, nsec => 888900000, posix => -500.1111
        },
        {
            given => -70.999,
            instant => Instant.from-posix(-70.999),
            expected => Instant.from-posix(-70.999),
            sec => -71, nsec => 1000000, posix => -70.999
        },
        {
            given => -50.000_000_1,
            instant => Instant.from-posix(-50.000_000_1),
            expected => Instant.from-posix(-50.000_000_1),
            sec => -51, nsec => 999999900, posix => -50.000_000_1
        },
        {
            given => -21.222_222_22,
            instant => Instant.from-posix(-21.222_222_22),
            expected => Instant.from-posix(-21.222_222_22),
            sec => -22, nsec => 777777780, posix => -21.222_222_22,
        },
        {
            given => -10.000_000_001,
            instant => Instant.from-posix(-10.000_000_001),
            expected => Instant.from-posix(-10.000_000_001),
            sec => -11, nsec => 999999999, posix => -10.000_000_001
        },
        {
            given => -3.000_01,
            instant => Instant.from-posix(-3.000_01),
            expected => Instant.from-posix(-3.000_01),
            sec => -4, nsec => 999990000, posix => -3.000_01
        },
        {
            given => -3.000_000_000_6,
            instant => Instant.from-posix(-3.000_000_000_6),
            expected => Instant.from-posix(-3.000_000_000_6),
            sec => -4, nsec => 999_999_999, posix => -0.300_000_000_6
        },
        {
            given => -1.4,
            instant => Instant.from-posix(-1.4),
            expected => Instant.from-posix(-1.4),
            sec => -2, nsec => 6 * 10⁸, posix => -1.4
        },
        {
            given => -0.4,
            instant => Instant.from-posix(-0.4),
            expected => Instant.from-posix(-0.4),
            sec => -1, nsec => 6 * 10⁸, posix => -0.4
        },
        {
            given => -0,
            instant => Instant.from-posix(-0),
            expected => Instant.from-posix(-0),
            sec => 0, nsec => 0, posix => -0
        },
        {
            given => 0,
            instant => Instant.from-posix(0),
            expected => Instant.from-posix(0),
            sec => 0, nsec => 0, posix => 0,
        },
        {
            given => 0.44,
            instant => Instant.from-posix(0.44),
            expected => Instant.from-posix(0.44),
            sec => 0, nsec => 44 * 10⁷, posix => 0.44
        },
        {
            given => 5.999,
            instant => Instant.from-posix(5.999),
            expected => Instant.from-posix(5.999),
            sec => 5, nsec => 999000000, posix => 5.999
        },
        {
            given => 5.1,
            instant => Instant.from-posix(5.1),
            expected => Instant.from-posix(5.1),
            sec => 5, nsec => 100000000, posix => 0.000_000_000
        },
        {
            given => 10.000_000_001,
            instant => Instant.from-posix(10.000_000_001),
            expected => Instant.from-posix(10.000_000_001),
            sec => 10, nsec => 1, posix => 10.000_000_001
        },
        {
            given => 13.0001,
            instant => Instant.from-posix(13.0001),
            expected => Instant.from-posix(13.0001),
            sec => 13, nsec => 100000, posix => 13.0001
        },
        {
            given => 20.000_000_1,
            instant => Instant.from-posix(20.000_000_1),
            expected => Instant.from-posix(20.000_000_1),
            sec => 20, nsec => 100, posix => 20.000_000_1
        },
        {
            given => 40.000_000_000_9,
            instant => Instant.from-posix(40.000_000_000_9),
            expected => Instant.from-posix(40.000_000_000_9),
            sec => 40, nsec => 0, posix => 40.000_000_000_9
        },
        {
            given => 10² + 2,
            instant => Instant.from-posix(10² + 2),
            expected => Instant.from-posix(10² + 2),
            sec => 10² + 2, nsec => 0, posix => 10² + 2,
        },
        {
            given => 200.000_000_06,
            instant => Instant.from-posix(200.000_000_06),
            expected => Instant.from-posix(200.000_000_06),
            sec => 200, nsec => 60, posix => 200.000_000_06
        },
        {
            given => 117.44444,
            instant => Instant.from-posix(117.44444),
            expected => Instant.from-posix(117.44444),
            sec => 117, nsec => 444440000, posix => 117.44444
        },
        {
            given => 30.000_000_7,
            instant => Instant.from-posix(30.000_000_7),
            expected => Instant.from-posix(30.000_000_7),
            sec => 30, nsec => 700, posix => 30.000_000_7
        },
        ;


