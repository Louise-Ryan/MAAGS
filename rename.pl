#!/usr/bin/perl

my $filename=$ARGV[0];
chomp $filename;
my @array=(<*$filename>);

my $Gene;
my $Voc;
my $Vom;
my $VomVoc;

foreach $file(@array){
    if ($file =~ m/(.*?_)/i) {
	$Gene = $1;
	if ($file =~ m/(Vomeronasal_Vocalisation)/i) {
	    $VomVoc = $1;
	    $VomVoc = $VomVoc."_";
	    my  $newname = $Gene.$VomVoc."RefSeq_LOCs_Primates.fa";
	    print $newname."\n";
	    system("mv $file $newname");
	}elsif ($file =~ m/(Vocalisation)/i) {
	    $Voc = $1;
	    $Voc = $Voc."_";
	    my $newname = $Gene.$Voc."RefSeq_LOCs_Primates.fa";
	    print $newname."\n";
	    system("mv $file $newname");
	}elsif ($file =~ m/(Vomeronasal)/i) {
	    $Vom = $1;
	    $Vom = $Vom."_";
	    my $newname = $Gene.$Vom."RefSeq_LOCs_Primates.fa";
	    print $newname."\n";
	    system("mv $file $newname");
	}
    }
}
exit;

#PAX6_sequences_Vomeronasal_Vocalisation_all
