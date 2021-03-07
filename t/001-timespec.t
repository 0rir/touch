use v6.c;
# vim: ft=perl6 expandtab sw=4
use Test;
use lib $?FILE.IO.parent(2).add('lib');
use lib $?FILE.IO.parent;
use Touch;
use Time-data;

# Test creation of Timespec objects.

my constant $file = $?FILE.IO.parent(2).add('resources/testfile').path;

plan 3 * @test.elems + 4;

for @test -> %data {
    my $ts = Touch::Timespec.from-instant(%data<instant>);
    is $ts.sec, %data<sec>, 'ts.sec.';
    is $ts.nsec, %data<nsec>, 'Timespec set.';
    is $ts.Instant, %data<expected>, 'Timespec.Instant.';
}

my  $now-spec = Touch::Timespec.from-instant(Instant);
is $now-spec.sec, 0, 'Timespec default now has .sec == 0.';
is $now-spec.nsec, ((1 +< 30) - 1),
        'Timespec default now has .nsec == UTIME_NOW.';

my  $ignore-spec = Touch::Timespec.ignore-me;
is $ignore-spec.sec, 0, 'Timespec to ignore has .sec == 0.';
is $ignore-spec.nsec, ((1 +< 30) - 2),
        'Timespec to ignore has .nsec == UTIME_OMIT.';
