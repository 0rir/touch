use v6.c;
# vim: ft=perl6 expandtab sw=4
unit module Touch:ver<0.5.0>;
use NativeCall;
use NativeHelpers::CStruct;

our $MIN-POSIX = -10 ** 9;      # 1938-04-24T22:13:20Z
our $MAX-POSIX = 10 ** 10;      # 2286-11-20T17:46:40Z

my int32 $UTIME_NOW = ((1 +< 30) - 1);
my int32 $UTIME_OMIT = ((1 +< 30) - 2);

my constant NANO = 10 ** -9;

class Timespec is repr('CStruct') {
    has long  $.sec;
    has long  $.nsec;

    sub MIN-POSIX() is export {
        $MIN-POSIX
    }
    sub MAX-POSIX() is export {
        $MAX-POSIX
    }
    multi method from-instant (Instant:D $instant) {
        my $posixtime = $instant.to-posix[0];
        die "Error posix timestamp out of range."
        unless $MIN-POSIX <= $posixtime <= $MAX-POSIX;
        my Int $sec = $posixtime.round;
        my $nsec = ($posixtime - $sec).round(NANO);
        if $nsec < 0 {
            ++$nsec;
            --$sec;
        }
        $nsec ×= 10⁹;
        return self.bless(:$sec, :nsec($nsec.Int));
    }

    multi method from-instant (Instant:U) {
        return self.bless(:sec(0), :nsec($UTIME_NOW));
    }

    method Instant {
        Instant.from-posix($!sec + ($!nsec / 10⁹));
    }
}

our $OMIT is export = Timespec.new(:sec(0), :nsec($UTIME_OMIT));
our $NOW is export = Timespec.new(:sec(0), :nsec($UTIME_NOW));

my $NOW-NOW = {
    my $ret = LinearArray[Timespec].new(2);
    $ret[0] = Timespec.new(:sec(0), :nsec($UTIME_NOW));
    $ret[1] = Timespec.new(:sec(0), :nsec($UTIME_NOW));
    $ret.base;
}.();

my int32 $AT_FDCWD = -100;
my int32 $AT_SYMLINK_NOFOLLOW = 0x100;

sub utimensat (int32:D,
               str:D,
               Timespec:D,
               int32:D --> int32) is native {*}


# implicitly set both now
multi sub touch(Str:D $fname) is export {
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $NOW-NOW, 0);
}

# explicitly set both
multi sub touch(Str:D $fname, Instant:D $acc, Instant:D $mod) is export {
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($acc);
    $times[1] = Timespec.from-instant($mod);
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# explicitly set both with named args
multi sub touch(Str:D $fname, Instant:D :$access!, Instant:D :$modify!)
        is export {
    return touch($fname, $access, $modify);
    # XXX splat
}
# set access only
multi sub touch(Str:D $fname, Instant:D :$access!, Bool:D :ONLY($b)!)
        is export {
    die "Do not call touch with :ONLY false, omit :ONLY perhaps." unless $b;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $OMIT;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# set modify only
multi sub touch(Str:D $fname, Instant:D :$modify!, Bool:D :ONLY($b)!)
        is export {
    die "Do not call touch with :ONLY false, omit :ONLY instead." unless $b;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $OMIT;
    $times[1] = Timespec.from-instant($modify);
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# set access explicitly, modify to now
multi sub touch(Str:D $fname, Instant:D :$access!) is export {
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $NOW;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, $flag);
}

# set modify explicitly, access to now
multi sub touch(Str:D $fname, Instant:D :$modify!) is export {
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $NOW;
    $times[1] = Timespec.from-instant($modify);
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, $flag);
}

