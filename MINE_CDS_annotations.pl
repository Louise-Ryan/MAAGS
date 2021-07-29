#!/usr/bin/perl -w

#----------------------------------------------------------------------------------------------------------------------
#Set the filenames:

print "Enter prefix for all output file names:";
$FILE_PREFIX = <STDIN>;
chomp $FILE_PREFIX;

#FILE1
$isoform_seq_filename = $FILE_PREFIX."_all_isoforms_seqfile.txt";

#FILE2
$longest_isoform_seq_filename = $FILE_PREFIX."_all_longest_isoforms_seqfile.txt";;

#FILE3
$isoform_printout_file=$FILE_PREFIX."_all_isoforms_LOGFILE.txt";

#FILE4
$longest_isoform_log_filename =$FILE_PREFIX."_longest_isoforms_LOGFILE.txt";

#FILE5
$no_hit_list_filename =$FILE_PREFIX."_no_hit_list.txt";

#FILE6 #Usually comment this out after first run to obtain protein names
#$protein_filename =$FILE_PREFIX."_all_protein_names_seqfile.txt";

#FILE7
$isoform_discarded_file =$FILE_PREFIX."_discarded_longest_isoforms_LOGFILE.txt";

#FILE8
$longest_isoforms_kept = $FILE_PREFIX."_retained_longest_isoforms_LOGFILE.txt";

#FILE9
$final_seq_file =$FILE_PREFIX."_Final_seq_file.txt";


#------------------------------------------------------------------------------------------------------------------
#PULL ANNOTATED GENES FROM CDS ANNOTATION FILES, FOR REFSEQ GENOMES

#------------------------------------------------------------------------------------------------------------------
#1.1 import the target genes array from text file:

#ask for text file with gene  names and store the string as species_file_name 
print "Enter title of text file containing target gene names:";
$target_genes = <STDIN>;
chomp $target_genes; # remove empty line from species_file_name
unless ( open(TARGETGENES, $target_genes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @Target_genes = <TARGETGENES>;

#close the file
close TARGETGENES;

chomp(@Target_genes); # remove empty lines from array


#1.2. import the genome list array from text file

#ask for genome file list 
print "Enter title of text file containing genome filename list:";
$target_genomes = <STDIN>;
chomp $target_genomes; # remove empty line from species_file_name
unless ( open(TARGETGENES, $target_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @Target_genomes = <TARGETGENES>;

#close the file
close TARGETGENES;

chomp(@Target_genomes); # remove empty lines from array

#-----------------------------------------------------------------------------------------------------------------------------
#1.3. Pull all isoforms which match the target genes for all genomes and output as one text file

#declare variables
my $sequence_isoforms= "";
my $genome_id = "";
my $isoform_id = "";
my $no_hit_list = "";
#my $hits = "";
my $gene_id = "";
my ($gene_name, $protein_name, $alternative_name);


foreach my $genome(@Target_genomes){
    if ($genome =~ m/(GCF+[\S\s]+_cds)/){
        $genome_id = $1;
	$genome_id =~ s/_cds//;
	print "looking for ".$genome_id."\n";
foreach my $target(@Target_genes) {
    ($gene_name, $protein_name, $alternative_name) = split (/\|/, $target,3);
    print "Scanning genome for ". $gene_name." aka ".$protein_name." aka ".$alternative_name."\n";
    open(IN1, $genome); #read in the CDS file for species
    my $hits = "";
    {local $/ = ">lcl"; #  change line delimter
     while(<IN1>) {
	 chomp;
	my $line=$_; #store each line of the text file in $line
	if ($line =~ m/(\[gene\=$gene_name\])/i) {
	    $gene_id = $1;
	    $sequence_isoforms =$sequence_isoforms.">".$genome_id."_".$gene_id."split_term"."_".$line."\n";
	    $hits = $target; 
	}elsif ($line =~ m/.*\Q$protein_name\E.*?\]/i || $line =~ m/.*\Q$alternative_name\E.*?\]/i) { #if line matches protein name or alternative protein name
	    if ($line !~ m/.*$protein_name[0-9].*?\]/i &&
	        $line !~ m/.*$alternative_name[0-9].*?\]/i &&
		$line !~ m/.*$protein_name[\s][0-9].*?\]/i &&
		$line !~ m/.*$alternative_name[\s][0-9].*?\]/i &&
		$line !~ m/.*$protein_name.*associated.*?\]/i &&
		$line !~ m/.*$alternative_name.*associated.*?\]/i &&
		$line !~ m/.*$protein_name.*interacting.*?\]/i &&
		$line !~ m/.*$alternative_name.*interacting.*?\]/i &&
		$line !~ m/.*$protein_name.*substrate.*?\]/i &&
		$line !~ m/.*$alternative_name.*substrate.*?\]/i) { #THIS LONG CONDITIONAL IF REMOVES SPECIFIC STRINGS. WARNING!!! THIS MAY NEED EDITING DEPENDING ON GENE SET!!
		if ($line =~ m/(\[gene\=.*?\])/i) { #### if ($line =~ m/gene\=.*?\])/i) , Problem with gene=LOC is that, if gene =alternative name, and not gene=LOC, but protein name matches exactly, it will not be pullled despite being a hit.
		$gene_id = $1;
	        $sequence_isoforms =$sequence_isoforms.">".$genome_id."_".$gene_id."split_term"."_".$line."\n";
		$hits = $target;
	    }elsif ($line =~ m/(GENEID:.*?\])/i) {
		$gene_id = $1;
		$sequence_isoforms =$sequence_isoforms.">".$genome_id."_".$gene_id."split_term"."_".$line."\n";
		$hits = $target;
          	}
	    }
	}
        }if ($hits !~ m/$target/){ #If no hit for target for genome, append to no_hit_list
		    $no_hit_list = $no_hit_list.$target."|".$genome."\n";
                   }
              }
         }
    }
}
#print $sequence_isoforms;
close IN1;


#print $hit_list."\n\n";
print $no_hit_list."\n\n";



#Output all isoforms for target seqs as a text file, allow user to specify text file name
#print "Enter sequence isoforms output file name:";
#my $isoform_seq_filename = <STDIN>;
#chomp $isoform_seq_filename; # remove empty line from species_file_name
open my $FILE, ">", $isoform_seq_filename or die("Can't open file. $!");
print $FILE $sequence_isoforms;
close $FILE;    

#----------------------------------------------------------------------------------------------------
#2. Filter the output fasta file for the longest isoform transcripts and export txt file.
#----------------------------------------------------------------------------------------------------

#2.1. Filter for longest isoform for each gene

#!/usr/bin/perl
use List::Util qw(max); #allows me to use the max(array) function

#open fasta file
open(IN2,$isoform_seq_filename);

#Declare variables
my $fasta = "";
my @isoformlengths = "";
my $isoformlengths_var = "";
my %seqs =();
my ($gene, $isoform);
my $isoform_ID = "";
my $isoform_printout = "";
my $longest_seq = "";
my $protein_names ="";
my $isoform_acession = "";
my $longest_isoforms = "";

#foreach my $target(@Target_genes) {
#format the fasta file to save gene, transcript and sequence as keys:
while (<IN2>) {
    chomp;
    chomp;
  if (/>GC.*/) {
      ($gene, $isoform) = split (/split_term/, $_);
   }
   else {
        $seqs{$gene}{$isoform} .= $_;
    }
}

foreach $gene (sort keys %seqs) {
    my @isoformlengths = ""; # iterate over genes
    my $isoform_ID = "";
 
foreach $isoform (keys %{ $seqs{$gene} }) { # iterate over transcripts
    my $seq = $seqs{$gene}{$isoform};
    my $seq_length = length $seq;
    push (@isoformlengths, $seq_length);
}
    
my $unwanted_element = shift(@isoformlengths); #remove the empty first element of this array
my $longest_transcript_value = max(@isoformlengths); #find longest element in the array
   # print "\nTranscript lengths for ".$gene.":\n"."This is the longest transcript length: ". $longest_transcript_value."\n";
    $isoform_printout = $isoform_printout."\nTranscript lengths for ".$gene.":\n"."This is the longest transcript length: ". $longest_transcript_value."\n";
    $longest_isoforms = $longest_isoforms."\nTranscript lengths for ".$gene.":\n";
    
   foreach $isoform (keys %{ $seqs{$gene} }) {
   
   if ($isoform =~ m/(protein\=.*isoform.*?\])/){ #
       $isoform_ID = $1;
       $isoform_ID =~ s/\]//; #
       $isoform_ID =~ s/protein\=//;
   if ($isoform =~ m/(cds.*?\[)/){
   	$isoform_acession = $1;
   	$isoform_acession =~ s/cds_//;
   	$isoform_acession =~ s/\[//;
       }
   }elsif($isoform =~ m/(protein\=.*?\])/){
       $isoform_ID = $1;
       $isoform_ID =~ s/\]//;
       $isoform_ID =~ s/protein\=//;
    if ($isoform =~ m/(cds_.*?\[)/){
   	$isoform_acession = $1;
   	$isoform_acession =~ s/cds_//;
   	$isoform_acession =~ s/\[//;
   	}
   }
    my $seq = $seqs{$gene}{$isoform};
    my $seq_length2 = length($seq);
   if ($seq_length2 == $longest_transcript_value){
       $longest_isoforms = $longest_isoforms.$isoform_acession." ".$isoform_ID." Length: ".length($seq)."\n";
	$protein_names = $protein_names.$gene."|".$isoform_ID."\n";
	$isoform_printout = $isoform_printout.$isoform_acession." ".$isoform_ID." is the longest transcript. "."Length: ".length($seq)."\n";
	$protein_names = $protein_names.$gene."|".$isoform_ID."\n";
      $fasta = $fasta.$gene.$isoform."\n".$seq."\n\n";
    }else{ 
    $isoform_printout = $isoform_printout.$isoform_acession." ".$isoform_ID. " Length: ".length($seq)." ...This is too short! Discarding from final output! \n";}
}
}

close IN2;


#Output filtered isoforms fasta sequences  as a text file, allow user to specify text file name
#print "\nEnter longest isoform fasta output file name:";
#my $longest_isoform_seq_filename = <STDIN>;
#chomp $longest_isoform_seq_filename; # remove empty line from species_file_name
open my $FILE2, ">", $longest_isoform_seq_filename or die("Can't open file. $!");
print $FILE2 $fasta;
close $FILE2;

#Output isoform length logfile
#print "\nEnter output file name for isoform length printout log file:";
#my $isoform_printout_file = <STDIN>;
#chomp $isoform_printout_file; # remove empty line from species_file_name
open my $FILE3, ">", $isoform_printout_file or die("Can't open file. $!");
print $FILE3 $isoform_printout;
close $FILE3;

#Output list of the longest isoforms and acessions for each gene
#print "\nEnter output file name for longest isoform log file:";
#my $longest_isoform_log_filename = <STDIN>;
#chomp $longest_isoform_log_filename; # remove empty line from species_file_name
open my $FILE4, ">", $longest_isoform_log_filename or die("Can't open file. $!");
print $FILE4 $longest_isoforms;
close $FILE4;


#Output list of genes with no hit for a given genome
#print "\nEnter output file name for no hit list log file:";
#my $no_hit_list_filename = <STDIN>;
#chomp $no_hit_list_filename; # remove empty line from species_file_name
open my $FILE5, ">", $no_hit_list_filename or die("Can't open file. $!");
print $FILE5 $no_hit_list;
close $FILE5;

###OPTIONAL: comment out if don't want this
#print "\nEnter output file name for protein name list file:";
#my $protein_filename = <STDIN>;
#chomp $protein_filename; # remove empty line from species_file_name
#open my $FILE6, ">", $protein_filename or die("Can't open file. $!");
#print $FILE6 $protein_names;
#close $FILE6;

#--------------------------------------------------------------------------------------------------------------------
#3. Filter longest isoforms seq file for only ONE longest isoform. Isoform accessions for each gene are sorted by
# alphabet in decending order (z-->a) and then by number in decending order (1000 --> 10).
# Hence XP_10000 will be chosen over NP_10000
# AND NP_10000 will be chosen over NP_10
#---------------------------------------------------------------------------------------------------------------------

#Filter longest isoforms

#declare variables
my $isoforms_keep_list = "";
my $isoforms_keep_list_printout = "";
my $isoforms_discarded_list = "";
my $golden_isoform ="";
my $golden_isoform_protein_name = "";


use Sort::Key::Natural qw( rnatsort );


unless ( open(IN3, $longest_isoform_log_filename) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

 {local $/ = "Transcript lengths for" ;# >.*?:/;
 while(<IN3>) {
     chomp;
     my $line2 = $_;
     
   # print "\n\n This is the line :";
     {local $/ = "\n";
      my @splitarray  = split("\n",$line2);
      my @isoform_array = ();
      foreach $element(@splitarray){
	   if ($element =~ m/(XP_.*?\s)/i || $element =~ m/(NP_.*?\s)/i) {
	       my  $isoform_2 = $1;
	      $isoform_2 =~ s/\s//;
	       push (@isoform_array, $isoform_2);
	      if ($line2 =~ m/(>.*\[gene=.*?\])/ || $line2 =~ m/(>.*GeneID.*?\])/){
		  $list_gene = $1;
	       }
	   }
      }my @sorted = rnatsort @isoform_array;
      my $golden_isoform = shift @sorted;
      foreach $element(@splitarray){
	  if ($element =~ m/$golden_isoform/i){
	   $golden_isoform_protein_name = $element;
      }
     }
      $isoforms_keep_list = $isoforms_keep_list.$golden_isoform."\n";
      $isoforms_keep_list_printout = $isoforms_keep_list_printout.$list_gene.": ".$golden_isoform_protein_name.": ".$golden_isoform."\n";
       if (@sorted){
	   $isoforms_discarded_list = $isoforms_discarded_list.$list_gene.": Discarded isoforms: ".join(",", @sorted)."\n";
       }
     }
   }
 } 


close IN3;

#print "Keep Isoform List: \n";
#print $isoforms_keep_list;

#Use isoforms_keep_list to pull only sequences with these identifiers, to obtain a sequence file with just one isoform per gene
my $Filtered_longest_isoforms_seqfile = "";

my @isoform_keep_array = split(/\n/, $isoforms_keep_list);

my $unwanted_whitespace = shift @isoform_keep_array;

foreach my $target_isoform(@isoform_keep_array){
    print "looking for ".$target_isoform."\n";
    {local $/ = ">GC"; #  change line delimter
     open(IN3, $longest_isoform_seq_filename);
     while(<IN3>) {
	 chomp;
	my $line3=$_; #store each line of the text file in $line
	 if ($line3 =~ m/$target_isoform/i) {
	     $Filtered_longest_isoforms_seqfile = $Filtered_longest_isoforms_seqfile.">GC".$line3."\n";
        }
     }
  }
}


#print $Filtered_longest_isoforms_seqfile;

#Output discarded long isoform logfile
#print "\nEnter output file name for isoform discarded printout log file:";
#my $isoform_discarded_file = <STDIN>;
#chomp $isoform_discarded_file; # remove empty line from species_file_name
open my $FILE7, ">", $isoform_discarded_file or die("Can't open file. $!");
print $FILE7 $isoforms_discarded_list;
close $FILE7;


#Output list of isoforms retained
#print "\nEnter output file name for isoform discarded printout log file:";
#my $longest_isoforms_kept = <STDIN>;
#chomp $longest_isoforms_kept; # remove empty line from species_file_name
open my $FILE8, ">", $longest_isoforms_kept or die("Can't open file. $!");
print $FILE8 $isoforms_keep_list_printout;
close $FILE8;


#Output final sequence file
#print "\nEnter output file name for isoform discarProtein transcription factor SOXded printout log file:";
#my $final_seq_file = <STDIN>;
#chomp $final_seq_file; # remove empty line from species_file_name
open my $FILE9, ">", $final_seq_file or die("Can't open file. $!");
print $FILE9 $Filtered_longest_isoforms_seqfile;
close $FILE9;

my $directoryname= $FILE_PREFIX."_output_files";

system("mkdir $directoryname");
system("mv $FILE_PREFIX* $directoryname");


######################################################################################################################################################################
#4. Optional: Remove non-specific unwanted hits.                                                                                                                     #
######################################################################################################################################################################
# MOST mis-hits can be removed by filtering anything where: [gene=XXX] does not equal [gene=target]/[gene=LOC]                                                       #
# We don't want LOCs to be removed hence above statement [gene=target] OR [gene=LOC].                                                                                #
#                                                                                                                                                                    #
# For the LOC genes, we have to include specific statements to remove unwanted hits. For example:                                                                    #
# Target= Huntingtin. --> Huntingtin + interacting/assosiated will be removed                                                                                        #
# Target = Epidermal growth factor --> Epidermal growth factor receptor + substrate will be removed                                                                  #
# Target = Protein transcription factor SOX2 --> Protein transcription factor SOX21 will be removed                                                                  #
#                                                                                                                                                                    #
# Specify these specific statements in script below.                                                                                                                 #
#                                                                                                                                                                    #
#######################################################################################################################################################################





exit;
