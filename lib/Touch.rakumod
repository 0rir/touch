use v6;
# vim: ft=perl6 expandtab sw=4
unit module Touch:ver<0.5.0>;
use NativeCall;
use NativeHelpers::CStruct;

constant $MIN-POSIX = -10⁹;      # 1938-04-24T22:13:20Z
constant $MAX-POSIX =  10¹⁰;     # 2286-11-20T17:46:40Z

constant VALID-POSIX = $MIN-POSIX^..^$MAX-POSIX;

my int32 $UTIME_NOW  = ((1 +< 30) - 1);
my int32 $UTIME_OMIT = ((1 +< 30) - 2);

constant DOM-ERR = "Posix time not between $MIN-POSIX and $MAX-POSIX.";

class X::Touch::Out-of-range is Exception { method message { DOM-ERR } }

class X::Touch::Native is Exception {
    has Str $.call;
    has Int $.value;
    method message { "Native C '$.call' returned error:  $.value"; }
}

class Timespec is repr('CStruct') {
    has long  $.sec;
    has long  $.nsec;

    sub MIN-POSIX() is export { $MIN-POSIX }

    sub MAX-POSIX() is export { $MAX-POSIX }

    multi method from-instant (Instant:D $instant) {

        my $posixtime = $instant.to-posix[0];
        unless $posixtime ~~ VALID-POSIX {
            X::Touch::Out-of-range.new;
        }
        my Int $sec = $posixtime.round;
        my $nsec = ($posixtime - $sec).round(10⁻⁹);
        if $nsec < 0 {
            ++$nsec;
            --$sec;
        }
        $nsec ×= 10⁹;
        return self.bless(:$sec, :nsec($nsec.Int))
    }

    multi method from-instant (Instant:U) {
        return self.bless(:sec(0), :nsec($UTIME_NOW))
    }

    method Instant { Instant.from-posix($!sec + $!nsec ÷ 10⁹) }
}

our $OMIT    is export = Timespec.new(:sec(0), :nsec($UTIME_OMIT));
our $USE-NOW is export = Timespec.new(:sec(0), :nsec($UTIME_NOW));


my $BOTH-NOW = {
    my $ret = LinearArray[Timespec].new(2);
    $ret[0] = Timespec.new(:sec(0), :nsec($UTIME_NOW));
    $ret[1] = Timespec.new(:sec(0), :nsec($UTIME_NOW));
    $ret.base;
}.();

my int32 $AT_FDCWD = -100;

sub utimensat (int32:D,
               str:D,
               Timespec:D,
               int32:D --> int32) is native {*}

# implicitly set both to now
multi sub touch(Str:D $fname) is export {
    my $err = utimensat($AT_FDCWD, $fname, $BOTH-NOW, 0);
    if 0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err)
    }
}

# explicitly set both
multi sub touch(Str:D $fname, Instant:D $acc, Instant:D $mod) is export {
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($acc);
    $times[1] = Timespec.from-instant($mod);
    my $err = utimensat($AT_FDCWD, $fname, $times.base, 0);
    if 0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err)
    }
}

# explicitly set both with named args
multi sub touch(Str:D $fname, Instant:D :$access!, Instant:D :$modify!)
        is export {
    touch($fname, $access, $modify)
}

# set access only
multi sub touch(Str:D $fname, Instant:D :$access!,
        Bool:D :$only! where * == True) is export {
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $OMIT;
    my $err = utimensat($AT_FDCWD, $fname, $times.base, 0);
    if 0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err)
    }
}
multi sub touch(Str:D $fname, Instant:D :$access!,
        Bool:D :$ONLY! where * == True) is export {
    DEPRECATED(
        'touch( use :only not :ONLY)','0.0.5','0.0.6', :what( &?ROUTINE.name)
    );
    touch( $fname, :$access, :only);
}

# set modify only
multi sub touch(Str:D $fname, Instant:D :$modify!,
        Bool:D :$ONLY! where * == True) is export {
    DEPRECATED(
        'touch( use :only not :ONLY)','0.0.5','0.0.6', :what( &?ROUTINE.name)
    );
    touch( $fname, :$modify, :only);
}

multi sub touch(Str:D $fname, Instant:D :$modify!,
        Bool:D :$only! where * == True)
        is export {
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $OMIT;
    $times[1] = Timespec.from-instant($modify);
    my $err = utimensat($AT_FDCWD, $fname, $times.base, 0);
    if  0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err)
    }
}

# set access explicitly, modify to now
multi sub touch(Str:D $fname, Instant:D :$access!) is export {
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $USE-NOW;
    my $err = utimensat($AT_FDCWD, $fname, $times.base, $flag);
    if 0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err)
    }
}

# set modify explicitly, access to now
multi sub touch(Str:D $fname, Instant:D :$modify!) is export {
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $USE-NOW;
    $times[1] = Timespec.from-instant($modify);
    my $err = utimensat($AT_FDCWD, $fname, $times.base, $flag);
    if 0 ≠ $err {
        X::Touch::Native.new: :call('utimensat'), :err($err);
    }
}

