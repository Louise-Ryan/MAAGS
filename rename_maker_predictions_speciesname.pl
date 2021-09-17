#!/usr/bin/perl                                                                                                                 

my $fasta_file_extension = "fasta";
my @file_array = (<*$fasta_file_extension>);

my $Genome2Species = "Genome2Species.txt";
open(IN, $Genome2Species);
{
    local $/;
    $LIST = <IN>;
}
my @ARRAY = split("\n", $LIST);
foreach my $f(@ARRAY) {
    print "\n".$f;
}



#my $outfile;                                                                                                                   

#Declare variables
#my ($genome, $species);
#my $SPECIES;

#foreach my $file(@file_array) {
#    if ($file =~ m/(GC.*?_.*)?_Gene/i) {
#	my $GENOME = $1;
#    }
#    foreach my $line(@ARRAY) {
#	($genome, $species) = split("\t", $line);
#	if ($genome eq $GENOME) {
#	    $SPECIES = $species;
#	}
 #   }
  #  open(IN, $file);
   # {
    #    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
     #   $GENES = <IN>; #Stores contents of BLAST file into a scalor                                                             #
    #}
    #close IN;
    #my $outfile ="";
   #my $newheader="";
    #my $head="";
    #my $seq="";
    #my $GENE="";
    #my $ANNOTATION="";
    #my $PREDICTION="";
    #@GENES=[];
    #@GENES=split(/\>/,$GENES);
    #foreach $gene(@GENES) {
     #   if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
      #      $head=">".$1."\n";
       #     $seq=$2;
       # }
       # if ($head =~ m/(\>.*?_)/i) {
        #    $ANNOTATION = $1;
         #   chop($ANNOTATION);
        #}
        #if ($head =~ m/(GC.*?\_.*?\_)/i){
         #   $Genome = $1;
          #  chop($Genome);
        #}
        #if ($head =~ m/.*(Gene.*)?\s/) {
         #   $GENE=$1;
        #}
	#if ($head =~ m/.*?\s(.*?\))/i) {
         #   $PREDICTION = $1;
        #}
        #if ($Head1 =~ m/\>.*/i){
         #   $newheader = $ANNOTATION."_".$SPECIES."_".$GENE." ".$PREDICTION."\n";
          #  $outfile=$outfile.$newheader.$seq;
        #}
    #}
    #open my $NEWFILE, ">", $file or die("Can't open file. $!");
    #print $NEWFILE $outfile;
    #close $NEWFILE;
#}

#exit;
