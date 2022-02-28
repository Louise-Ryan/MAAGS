#!/usr/bin/perl
use List::Util qw(max); #allows me to use the max(array) function
my $PRIMATES = "Primates_Key.txt";
open(IN, $PRIMATES);
@Primates = <IN>;
close IN;

my $fasta_file_extension = "fasta";
my @ALIGNMENTS = (<*$fasta_file_extension>);

my $ISOFORM;
my $GENE_NAME;
my $file;

foreach my $alignment(@ALIGNMENTS){
    my $prefix = $alignment;
    $prefix =~ s/\.fasta//i;
    $outfile = $prefix."_longest.fa";
    my @array = ();
    my $count = 0;
    my $counter = 0;
    my @already = ();
    #my @already2 = ();
    my @output_genes = ();
    #print "Reading in $alignment ... \n";
    open(IN, $alignment);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$Alignment = <IN>; #Stores contents of BLAST file into a scalor
    }
    close IN;
    #print $Alignment;
    my @genes = split('\>', $Alignment);
    # foreach my $gene(@genes){
    foreach my $primate(@Primates){
	my @array= ();
	my @lengths = ();
	my @already = ();
	($key, $Species) = split (/\|/, $primate,2);
	$Species =~ s/\n//g;
	$key =~ s/\n//g;
	foreach my $gene(@genes){
	    if ($gene =~ m/.*\_$key.*\n(.*)/i){
		# print $gene."\n";
		my $length = length $gene;
		push (@lengths, $length);
		push (@array, $gene);
	    }
	}
	chomp @array;
	my $longest_dup = max(@lengths);
	#print "This is the longest dup: $longest_dup\n";
	foreach my $hit (@array){
	    $close_loop = 0;
	    # print $hit."\n";
	    my $length_hit = length $hit;
	    $length_hit +=1;
	 #   print "This is the compared length: $length_hit\n";
	    if ($length_hit == $longest_dup && $hit !~ @already){
		push (@already, $hit);
		$fasta = ">".$hit;
		push(@output_genes, $fasta);
	    }
	}
    }
    foreach my $gn(@output_genes){
	open my $FILE, ">>", $outfile or die("Can't open file. $!");
	print $FILE $gn."\n";
	close $FILE;
	#print $gn."\n";
    }
}
