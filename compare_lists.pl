#!/usr/bin/perl

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

my @array1 = (<*$file1>);
my @array2 = (<*$file2>);

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
