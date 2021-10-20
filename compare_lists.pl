#!/usr/bin/perl

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

open(IN, $file1);
@array1 = <IN>;
close IN;

open(IN2, $file2);
@array2 = <IN2>;
close IN2;

my $store;
foreach my $element(@array1) {
    $store = $store.$element."_";
}
print $store."\n";

foreach my $entry(@array2) {
    if ($store !~ m/.*$entry.*/i) {
	print $entry;
    }
}
