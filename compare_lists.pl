#!/usr/bin/perl

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

open(IN, $file1);
@array1 = <IN>;
close IN;

open(IN2, $file2);
@array2 = <IN2>;
close IN2;

$array2 = join('', @array2);
$array2 =~ s/\n//g;
#$array2 = "|".$array2."|";
#print $array2;

my $store;

foreach my $entry(@array1) {
    $entry =~ s/\n//g;
    $entry =~ s/\s//g;
#    print $entry;
    if ($array2 !~ m/$entry/i){
	#print "\n\n".$entry."is not in gene alignment";
	$store = $store.$entry."\n";
    }elsif ($array2 =~ m/$entry/i) {
#	print "\n\n".$entry."eq";
    }else{
	print "\nwtf is going on?\n";
    }
}

print $store;

exit;
