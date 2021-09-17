#!/usr/bin/perl

my $Genome2Species = $ARGV[0]; #This is the text file with the genome and species information. Format of text file is: Genome\tGenus_Species

#my $Genome2Species = "Genome2Species.txt";

my $fasta_file_extension = "fasta";
my @file_array = (<*$fasta_file_extension>);


open(IN, $Genome2Species);
{
    local $/;
    $LIST = <IN>;
}
my @ARRAY = split("\n", $LIST);
chomp @ARRAY;


#Declare variables
#my ($genome, $species);
my $SPECIES;
my $GENOME;

foreach my $file(@file_array) {
    print "\nRenaming headers for ".$file."....";
    if ($file =~ m/.*(GC.*?_.*?\.\d).*/i) {
	$GENOME = $1;
	#print $GENOME."\n";
    }
    foreach my $line(@ARRAY) {
	($genome, $species) = split("\t", $line);
	if ($genome =~ m/$GENOME/i) {
	    #print $genome." is equal to ".$GENOME;
	    $SPECIES = $species;
	    #print " ....This is the species: ".$SPECIES."\n";
	}
    }
    open(IN, $file);
    {
        local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; #Stores contents of BLAST file into a scalor
    }
    close IN;
    my $outfile ="";
    my $newheader="";
    my $head="";
    my $seq="";
    my $GENE="";
    my $ANNOTATION="";
    my $PREDICTION="";
    my $Genome_ID;
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
       if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
          $head=">".$1."\n";
          $seq=$2;
       }
       if ($head =~ m/(\>.*?_)/i) {
           $ANNOTATION = $1;
           chop($ANNOTATION);
	  # print $ANNOTATION."\n";
       }
       if ($head =~ m/(GC.*?\_.*?\_)/i){
          $Genome_ID = $1;
          chop($Genome_ID);
	  #print $Genome_ID."\n";
       }
       if ($head =~ m/.*(Gene.*)\s\(/i) {
	   $GENE=$1;
	   #print $GENE."\n";
       }
       if ($head =~ m/.*?\s(.*?\))/i) {
	   $PREDICTION = $1;
	  # print $PREDICTION."\n";
       }
       if ($head =~ m/\>.*/i){
          $newheader = $ANNOTATION."_".$SPECIES."_".$GENE." ".$Genome_ID." ".$PREDICTION."\n";
	  $outfile=$outfile.$newheader.$seq;
        }
    }
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

exit;
