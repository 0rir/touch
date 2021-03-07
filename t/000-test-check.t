use v6.c;
# vim: ft=perl6 expandtab sw=4
use lib $?FILE.IO.parent;
use NativeCall;
use Time-data;
use Test;

# Test test expectation generator against hand-made data.

plan 7 × $expectation-tests.elems;

for $expectation-tests.List -> $g {
    my $got = expectation($g<given>);
    is $got<given>, $g<given>, "Given. $g<given>";
    is $got<instant>, $g<instant>, "Instant. $g<instant>";
    is $got<expected>, $g<expected>, "Expected. $g<expected>";
    is $got<sec>, $g<sec>, "  Sec. $g<sec>";
    is $got<posix>, $g<posix>, "Posix. $g<posix>";
    is $got<nsec>, $g<nsec>, " Nsec. $g<nsec>";
    is $got.keys.elems, 6, "No extra keys.";
}
done-testing;

