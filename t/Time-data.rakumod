use v6.c;
# vim: ft=perl6 expandtab sw=4
unit module Time-data;
use NativeCall;
use Test;

my Rat $machine-takes = 0.01;
# seconds to touch then get stat back
our $LAG is export = %*ENV<LAG> // $machine-takes;

our @test is export = flat (
0,
0.4,
0.999,
1.4,
3.00001,
5.1,
7.4,
10.000_000_001,
10.000_000_1,
10.000_000_7,
10.000_000_000_9,
12.000_000_000_1,
107.4,
62167219190,
-0,
-0.4,
-0.999,
-1.4,
-3.00001,
-5.1,
-7.4,
-10.000_000_001,
-10.000_000_1,
-10.000_000_7,
-10.000_000_000_9,
-12.000_000_000_1,
-107.4,

#10**19,                        # Cannot unbox to native long
#10**18 × 9.223372036854770000,   # diff 373 seconds
#10**18 +18,             # diff  55
#10**17 +17,             # diff  6
#10**16 +16,             # diff  1
#10**15 +15,
#10**14 +14,

10 ** 13,
10 ** 12 + 12,
10 ** 11 + 11,
10 ** 10 + 10,
10 ** 9 + 9,
10 ** 8 + 8,
10 ** 7 + 7,
10 ** 6 + 6,
10 ** 5 + 5,
10 ** 4 + 4,
10 ** 3 + 3,
10 ** 2 + 2,
-21 .. 21,
-10 ** 2 - 2,
-10 ** 3 - 3,
-10 ** 4 - 4,
-10 ** 5 - 5,
-10 ** 6 - 6,
-10 ** 7 - 7,
-10 ** 8 - 8,
-10 ** 9 - 9,
-10 ** 10 - 10,
-10 ** 11 - 11,
-10 ** 12,

#-10**13 - 13,
#-10**14 - 14,
#-10**15 - 15,
#-10**16 + 16,
#-10**17 - 17,               # diff 7
#-10**18 - 18,               # diff  8
#-10**18 × 9.22337203685477,             # diff  326
#-10**19 - 19,      # cannot unbox
);

for @test -> $x is rw { $x = expectation($x); }

sub expectation (Numeric $in --> Hash) is export {
    my $posix = $in;
    my ($sec, $nsec);
    $posix .= round(0.000_000_001);
    my $fract = $posix - $posix.Int;
    ($sec, $nsec) = ($posix < 0 and $fract ≠ 0)
            ?? ($posix.floor, 1 + $fract)
            !! ($posix.Int, $fract);
    return (
    given => $in.Rat,
    posix => $posix,
    instant => Instant.from-posix($in),
    expected => Instant.from-posix($posix),
    sec => $sec.Int,
    nsec => ($nsec × 10⁹).round.Int,
    ).Hash;
}


our $expectation-tests is export = (
{
    given => -0.0,
    instant => Instant.from-posix(0),
    expected => Instant.from-posix(0),
    sec => 0, nsec => 0, posix => 0,
},
{
    given => 0,
    instant => Instant.from-posix(0),
    expected => Instant.from-posix(0),
    sec => 0, nsec => 0, posix => 0,
},
{
    given => 0.4,
    instant => Instant.from-posix(0.4),
    expected => Instant.from-posix(0.4),
    sec => 0, nsec => 4 * 10⁸, posix => 0.4
},
{
    given => -0.4,
    instant => Instant.from-posix(-0.4),
    expected => Instant.from-posix(-0.4),
    sec => -1, nsec => 6 * 10⁸, posix => -0.4
},
{
    given => -1,
    instant => Instant.from-posix(-1),
    expected => Instant.from-posix(-1),
    sec => -1, nsec => 0, posix => -1
},
{
    given => 1,
    instant => Instant.from-posix(1),
    expected => Instant.from-posix(1),
    sec => 1, nsec => 0, posix => 1
},
{
    given => 1.4,
    instant => Instant.from-posix(1.4),
    expected => Instant.from-posix(1.4),
    sec => 1, nsec => 4 * 10⁸, posix => 1.4
},
{
    given => -1.4,
    instant => Instant.from-posix(-1.4),
    expected => Instant.from-posix(-1.4),
    sec => -2, nsec => 6 * 10⁸, posix => -1.4
},
{
    given => 1.000_000_000_6,
    instant => Instant.from-posix(1.000_000_000_6),
    expected => Instant.from-posix(1.000_000_001),
    sec => 1, nsec => 1, posix => 1.000_000_001
},
{
    given => -1.000_000_000_6,
    instant => Instant.from-posix(-1.000_000_000_6),
    expected => Instant.from-posix(-1.000_000_001),
    sec => -2, nsec => 999_999_999, posix => -1.000_000_001
},
{
    given => 0.000_000_000_6,
    instant => Instant.from-posix(0.000_000_000_6),
    expected => Instant.from-posix(0.000_000_001),
    sec => 0, nsec => 1, posix => 0.000_000_001
},
{
    given => -0.000_000_000_6,
    instant => Instant.from-posix(-0.000_000_000_6),
    expected => Instant.from-posix(-0.000_000_001),
    sec => -1, nsec => 999_999_999, posix => -0.000_000_001
},
{
    given => 0.000_000_000_4,
    instant => Instant.from-posix(0.000_000_000_4),
    expected => Instant.from-posix(0.000_000_000),
    sec => 0, nsec => 0, posix => 0.000_000_000
},
);

