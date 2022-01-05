
NAME

Touch -- set file modified and/or accessed time

SYNOPSIS

use Touch;

touch( $filename );                     # update both to now
touch( $filename, $access, $modify );   # update both
touch( $filename, :$access!, :$modify! ); # update both
touch( $filename, :$access!, :ONLY! );  # update access only
touch( $filename, :$access! );          # update access, set mtime to now
touch( $filename, :$modify!, :ONLY! );  # update modify only
touch( $filename, :$modify! );          # update atime, set atime to now



DESCRIPTION

Touch is a wrapping of C<C>s utimensat call. It allows the
setting of file access and modify times.

The Instant type is used to express all time values seen
in Raku.  Instants being passed to C<touch> representing
times in the years from 1939 to 2285 inclusive are valid.
The formal limits are in $MIN-POSIX and $MAX-POSIX as
posix time values.

When an access or modify argument is absent, its default is no
w.
Use the :ONLY flag to leave the absent timestamp unchanged.
All given arguments must be defined.

Symlinks are always followed. Acting on symlinks directly is n
ot supported.  This mirrors Raku's behavior when when reading file
times.

All of these die on failure. Exceptions are NYI.

CAVEATS

Alpha code.  Run the tests.  If tests fail, you may increase the
lag allowance for writing and reading back a timestamp.   Set $LAG
in the environment.  0.01 second is the default.

The Timespec code may be moved to a separate module.

The calling interface is not to be considered stable yet.  There
are no plans to change.  It is supposed to be accomodating and easy.
Feedback is welcome. 

AUTHOR

Robert Ransbottom

SEE ALSO

joy / the clouds / ride the zephyr / warm they smile / die crying

COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.
Copyright 2021 rir.


