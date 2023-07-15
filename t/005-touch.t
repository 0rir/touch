use v6.c;
# vim: ft=perl6 expandtab sw=4
use Test;
use lib $?FILE.IO.cleanup.parent(2).add('lib');
use lib $?FILE.IO.cleanup.parent(1);
use Touch;
use Time-data;
use NativeCall;
use NativeHelpers::CStruct;


diag "Test lag allowance is $LAG seconds. Environment \$LAG can be adjusted.";

constant $control = Instant.from-posix(-11121);

plan 2 + 2 + 2 + 12 * @test.elems;

my $initial-modify = $file.IO.modified;
my $initial-access = $file.IO.accessed;

my ($acc, $mod, $now);

touch($file);
$now = now;
$acc = $file.IO.accessed;
$mod = $file.IO.modified;
is-approx $acc, $now, $LAG, 'touch( $f), access NOW';
is-approx $mod, $now, $LAG, 'touch( $f), modify NOW';

for @test -> $t {
    touch($file, $t<instant>, $t<instant>);
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is-approx $acc, $t<expected>, $LAG,
            "touch( \$f, \$a, \$m) access: $t<instant>.DateTime.Str()";
    is-approx $mod, $t<expected>, $LAG,
            "touch( \$f, \$a, \$m) modify: $t<instant>.DateTime.Str()";

}

for @test -> $t {
    touch($file, :access($t<instant>), :modify($t<instant>));
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is-approx $acc, $t<expected>, $LAG,
            "touch( \$f, \$a, \$m) access: $t<given>";
    is-approx $mod, $t<expected>, $LAG,
            "touch( \$f, \$a, \$m) modify: $t<given>";
}

for @test -> $t {
    touch($file, :access($t<instant>));
    $now = now;
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is-approx $acc, $t<expected>, $LAG,
            "touch( \$f, \$a) access: $t<given>";
    is-approx $mod, $now, $LAG, "touch( \$f, \$a) modify: $t<given>";
}

for @test -> $t {
    touch($file, :modify($t<instant>));
    $now = now;
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is-approx $acc, $now, $LAG, "touch( \$f, \$a) access: $t<given>";
    is-approx $mod, $t<expected>, $LAG, "touch( \$f, \$m) modify: $t<given>";
}

touch($file, $control, $control);
is $file.IO.accessed, $control, "Setup control access time.";
is $file.IO.modified, $control, "Setup control modify time.";

for @test -> $t {
    touch($file, access => $t<instant>, :ONLY);
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is-approx $acc, $t<expected>, $LAG,
            "touch( \$f, :\$access, :ONLY) access: $t<given>";
    is $mod, $control, "touch( \$f, :\$access, :ONLY) modify: $t<given>";
}

touch($file, $control, $control);
is $file.IO.accessed, $control, "Setup";
is $file.IO.modified, $control, "Setup";

for @test -> $t {
    touch($file, :modify($t<instant>), :ONLY);
    $acc = $file.IO.accessed;
    $mod = $file.IO.modified;
    is $acc, $control, "touch( \$f, :\$modify, :ONLY) access: $t<given>";
    is-approx $mod, $t<expected>, $LAG,
            "touch( \$f, :\$modify, :ONLY) modify: $t<given>";
}

touch $file, $initial-access, $initial-modify;

done-testing;

