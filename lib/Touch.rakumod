use v6.c;
# vim: ft=perl6 expandtab sw=4
unit module Touch:ver<0.5.0>;
use NativeCall;
use NativeHelpers::CStruct;


=begin pod

=head1 NAME

Touch - set file modify and access times

=head1 SYNOPSIS

=begin code :lang<raku>

use Touch;

touch( $filename, :NO-FOLLOW);
touch( $filename, $access, $modify, :NO-FOLLOW);
touch( $filename, :$access!, :$modify!, :NO-FOLLOW )
touch( $filename, :$access!, :ONLY!, :NO-FOLLOW);
touch( $filename, :$access!, :NO-FOLLOW);
touch( $filename, :$modify!, :ONLY!, :NO-FOLLOW);
touch( $filename, :$modify!, :NO-FOLLOW);

=end code

=head1 DESCRIPTION

Touch is a wrapping of C<C>s utimensat call. It allows the
setting of file access and modify times.

The Instant type is used to express all time values seen
in Raku.  Instants being passed to C<touch> must be from
-29719-04-05T22:13:20Z  to +318857-05-20T17:46:40Z inclusive.

When an access or modify argument is absent, its default is now.
Use the :ONLY flag to leave the absent timestamp unchanged.
All given arguments must be defined.
NO-FOLLOWing of symlinks is not yet implemented.
All of these die on failure.

=head1 CAVEATS

The calling interface is not to be considered stable yet.  It is
supposed to be accomodating and easy.  Feedback is welcome. 

So far only tested on 64 bit linux.

If tests fail, you may increase the lag allowance for writing
and reading back a timestamp.   Set $LAG in the environment.
0.01 second is the default.

One host, with a Intel 2400Mhz processor and SSDs, lags around
0.006 seconds.

Distant time values are inaccurate-ish.  Precision is lost.
Since there is a unlikely situation where being off by five minutes
could be inconvenient, the range of allowed values is constrained.

=head1 AUTHOR

Robert Ransbottom

=head1 SEE ALSO

joy / the clouds / ride the zephyr / warm they smile / die crying

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.
Copyright 2021 rir.

=end pod


my Int $MIN-POSIX = -10 ** 12;
# -29719-04-05T22:13:20Z   12
my Int $MAX-POSIX = 10 ** 13;
# +318857-05-20T17:46:40Z  13
my int32 $UTIME_NOW = ((1 +< 30) - 1);
my int32 $UTIME_OMIT = ((1 +< 30) - 2);
my constant NANO = 1 * 10 ** -9;

class Timespec is repr('CStruct') {
    has long  $.sec;
    has long  $.nsec;

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

    multi method from-instant (Instant:U ) {
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
multi sub touch(Str:D $fname, Bool :$NO-FOLLOW ) is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $NOW-NOW, 0);
}

# explicitly set both
multi sub touch(Str:D $fname,
                Instant:D $acc, Instant:D $mod, Bool :$NO-FOLLOW ) is export {
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($acc);
    $times[1] = Timespec.from-instant($mod);
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# explicitly set both with named args
multi sub touch(Str:D $fname, Instant:D :$access!, Instant:D :$modify!,
                Bool :$NO-FOLLOW) is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    return touch($fname, $access, $modify); # XXX splat
}
# set access only
multi sub touch(Str:D $fname, Instant:D :$access!, Bool:D :ONLY($b)!,
                Bool :$NO-FOLLOW ) is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    die "Do not call touch with :ONLY false, omit :ONLY perhaps." unless $b;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $OMIT;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# set modify only
multi sub touch(Str:D $fname, Instant:D :$modify!, Bool:D :ONLY($b)!,
                Bool :$NO-FOLLOW) is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    die "Do not call touch with :ONLY false, omit :ONLY instead." unless $b;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $OMIT;
    $times[1] = Timespec.from-instant($modify);
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, 0);
}

# set access explicitly, modify to now
multi sub touch(Str:D $fname, Instant:D :$access!, Bool :$NO-FOLLOW)
        is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = Timespec.from-instant($access);
    $times[1] = $NOW;
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, $flag);
}

# set modify explicitly, access to now
multi sub touch(Str:D $fname, Instant:D :$modify!, Bool :$NO-FOLLOW)
        is export {
    die "Don't set optional :NO-FOLLOW;  not yet implemented." if $NO-FOLLOW;
    my $flag = 0;
    my $times = LinearArray[Timespec].new(2);
    $times[0] = $NOW;
    $times[1] = Timespec.from-instant($modify);
    die "Native utimensat failed."
    if 0 ≠ utimensat($AT_FDCWD, $fname, $times.base, $flag);
}

