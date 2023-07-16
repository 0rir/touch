use v6.c;
# vim: ft=perl6 expandtab sw=4
use Test;
use lib $?FILE.IO.cleanup.parent(2).add('lib');
use lib $?FILE.IO.cleanup.parent;
use Touch;
use Time-data;

# Test creation of Timespec objects.

plan 3 * @test.elems + 2 + 2;

for @test -> %data {
    my $ts = Touch::Timespec.from-instant(%data<instant>);
    is $ts.sec, %data<sec>, 'ts.sec set';
    is $ts.nsec, %data<nsec>, 'ts.nsec set.';
    is $ts.Instant, %data<expected>, 'Timespec.Instant.';
}

my  $now-spec = Touch::Timespec.from-instant(Instant);
is $now-spec.sec, 0, 'Timespec default now has .sec == 0.';
is $now-spec.nsec, ((1 +< 30) - 1),
        'Timespec default now has .nsec == UTIME_NOW.';


dies-ok {
    my $ts = Touch::Timespec.from-instant(
            Instant.from-posix(Touch::Timespec.MIN-POSIX - 1))
},
        'Timespec value too small';
dies-ok {
    my $ts = Touch::Timespec.from-instant(
            Instant.from-posix(Touch::Timespec.MAX-POSIX + 1))
},
        'Timespec value too large';

done-testing;
