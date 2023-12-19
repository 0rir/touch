
NAME
====

Touch -- set file modified and/or accessed time

SYNOPSIS
========

    use Touch;

    touch( $filename);                       # set atime and mtime to now
    touch( $filename, $access, $modify);     # set both
    touch( $filename, :$access!, :$modify!); # set both w/ named args
    touch( $filename, :$access!, :only!);    # set access only
    touch( $filename, :$access!);            # set access, set mtime to now
    touch( $filename, :$modify!, :only!);    # set modify only
    touch( $filename, :$modify!);            # set mtime, set atime to now

DESCRIPTION
===========

Touch is a wrapping of C<C>s utimensat call. It allows the
setting of file access and modify times.

The Raku Instant type is used to express all time values seen
in Raku.  Instants being passed to C<touch> representing
times in the years from 1939 to 2285 inclusive are valid.
The formal limits are in $MIN-POSIX and $MAX-POSIX as
posix time values.

When an access or modify argument is absent, its default is now.
Use the :only flag to leave the absent timestamp unchanged.
All given arguments must be defined.  :ONLY is deprecated.

Exceptions that may be thrown: C<X::Touch::Out-of-range> and
C<X::Touch::Native>.

Symlinks are always followed. Acting on symlinks directly is not
supported.  This mirrors Raku's behavior when when reading file
times.

CAVEATS
=======

Alpha code.  Run the tests.  If tests fail, you may increase the
lag allowance for writing and reading back a timestamp.   Set $TESTLAG
in the environment.  0.01 second is the default.

The calling interface is not to be considered stable yet.  There
are no plans to change.  Feedback is welcome, It is supposed to be
accomodating and easy.

AUTHOR
======

Robert Ransbottom

SEE ALSO
========

joy / the clouds / ride the zephyr / warm they smile / die crying

COPYRIGHT AND LICENSE
=====================

Copyright 2021-2023 Robert Ransbottom.

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

