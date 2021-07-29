#!/usr/bin/perl 

#------------------------------------------------------------------------------------------------------------------
#PULL CONTIGS FROM blastn OUTFILE
#parse blastn output file. Pull contig hit name and store in an array. Only store unique hits where genes from multiple species are used as blastn input.
#Pull scores and contig info and stores in Contig_Hit_Summary.txt.
#Opens Genome file and pulls unique contigs from the target genome and stores in Contig_Hit_SeqFile.fa.
#Run this script on one blast output file corresponding to one target genome at a time.
#Can handle multiple genes from multiple species as blast query against target genome.

#ARGV0=Blast output file name
#ARGV1=Target Genome


#------------------------------------------------------------------------------------------------------------------
#1.1 Open and parse the blast output text file. Output blast hit summary per query. Store unique contig hits in array for part 1.2.

#open blast output file
my $BLAST_Out_File = $ARGV[0]; #First argument of command is the BLAST out file to parse
chomp $BLAST_Out_File; 
unless ( open(BLASTFILE, $BLAST_Out_File) ) {  
     print "Filename entered does not exist \n ";
	exit;
}


#Declare variables
my $Blast_output;
my $Query = "";
my $Contig = "";
my $EValue = "";
my $Score = "";
my $Identity = "";
my $Gaps = "";
my $Strand = "";
my $Contig_List = ""; #Will convert this to array using split after all looping
my @Contig_array = "";
my $Contig_Hit_Summary = "";
my $Database ="";
my $Contig_check ="";
my $GENOME_ID ="";


#Read file contents into scalar and convert to array using split. Each element is a blast query result.

{
    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
    $Blast_output = <BLASTFILE>; #Stores contents of BLAST file into a scalor
}

my @Blast_array = split("Query\=", $Blast_output); #Splits by query and stores each query as an element of the array that can be looped over



#Loop over each query in blast file and pull unique contigs with blast hits. Each query is gene per species. Can also take multiple genes as input from multiple species. Will only output unique contigs, so if two hits for two different genes hit the same contig, that contig will not be repeated inthe final fasta seq from part 1.2.


foreach my $line(@Blast_array) { #each query chunk is stored in $line from blast output file
    # print $line."\n";
    if ($line =~ m/(\s.*\n?GC)/i){
	my $Query = $1; #Query is "GENE_Genus_species" info
	$Query =~ s/\nGC//;
	$Query =~ s/\s//;
	if ($Query !~ m/Database/i) { #RegEx was not specific enough so removing this non-specific hit
	    $Contig_Hit_Summary = $Contig_Hit_Summary."\n"."Query = ".$Query.", "; #Add query info to summary file
	} if ($line =~ m/(Database.*?fna)/i) { #storing the database (genome being blasted) info (will be added to sumamry at end)
	    $Database = $1
	}
	if ($line =~ m/(\>.*?\s)/i) { 
	    $Contig = $1; #Storing Contig Hit identifier
	    $Contig =~ s/\>//;
	    $Contig =~ s/\s//;
	    $Contig = $Contig."_"; #Add underscore to identifier. Important for contig check. Removed again later on.
	    if ($Contig !~ m/$Contig_check/g) { #If unique contig hit, store to contig list
		$Contig_check = $Contig;
		$Contig_List = $Contig_List.$Contig;
	    }
	    $Contig =~ s/\_//;
	    $Contig_Hit_Summary = $Contig_Hit_Summary.$Contig.", "; #Store contig identifier in summary file
	    if ($line =~ m/(Score\s\=.*?\,)/i) {
		$Score = $1; #Store score (bits) info in summary file
		$Contig_Hit_Summary = $Contig_Hit_Summary.$Score; 
		if ($line =~ m/(Expect\s\=.*[0-9].*e.*[0-9])/i) {
		    $EValue = $1; #Store e-value score info in summary file
		    $Contig_Hit_Summary = $Contig_Hit_Summary." ".$EValue.", ";
		    if ($line =~ m/(Identities\s\=.*?\,)/i) {
			$Identity = $1; #Store Identity score in summary file
			$Contig_Hit_Summary = $Contig_Hit_Summary.$Identity;
			if ($line =~ m/(Gaps\s\=.*?\))/i) {
			    $Gaps = $1; #Store Gap info in summary file
			    $Contig_Hit_Summary = $Contig_Hit_Summary." ".$Gaps.", ";
			    if ($line =~ m/(Strand\=.*\/.*?\n)/i) {
				$Strand = $1; #Store strand info in summary file
				$Strand =~ s/\n//;
				$Contig_Hit_Summary = $Contig_Hit_Summary.$Strand;
			    }
			}
		    }
		}
	    }
	}
    }
}

$Contig_Hit_Summary = "Blast results against ".$Database.":".$Contig_Hit_Summary."\n\n"."Unique Contig Hits: \n"; #Add database info to summary file.

@Contig_array = split("_",$Contig_List); #Split the unique contigs into an array. This is where the underscore is important.

foreach my $Contig_ID (@Contig_array) { #Loop over array and print unique contig list to summary file
    $Contig_Hit_Summary = $Contig_Hit_Summary.$Contig_ID."\n";
}

print $Contig_Hit_Summary."\n\n"; 


#Output summary file as GENOME_Contig_hits_summary_file.txt

if ($Database =~ m/(GC.*?\_.*?\_)/i){ #Getting Genome ID for output file names
    $GENOME_ID = $1;
    chop($GENOME_ID);
}

my $Contig_Hit_Summary_File = $GENOME_ID."_Contig_Hit_Summary_File.txt"; #Set Summary File name

open my $FILE1, ">", $Contig_Hit_Summary_File or die("Can't open file. $!"); #Output Summary File
print $FILE1 $Contig_Hit_Summary;
close $FILE1;

#print $sequence_isoforms;
close BLASTFILE;



#------------------------------------------------------------------------------------------------------------------
#1.2 Open genome file and pull contigs with blast hit. Output Contig to file with sensible name for MAKER input.


#Open Genome file
my $GENOME = $ARGV[1]; #Second  argument of command is the genome file to parse
chomp $BLAST_Out_File; 
unless ( open(GENOME, $GENOME) ) {  #open the file. If it doesnt exist, exit and print an error
    print "Filename entered does not exist \n ";
	exit;
}


#Declare Variables:
my $contig_seq = "";
my $CONTIG_HIT = "";


#Parse Genome file and pull contigs where a blast hit was detected. Contig hits are stored in @Contig_array from section 1.1.

foreach my $Contig_ID(@Contig_array) {
    print "Pulling ".$Contig_ID." from ".$GENOME."...\n";
    {local $/ = ">"; #  change line delimter to read in file by contig
     open(GENOME, $GENOME); #Open the genome file
     while(<GENOME>) {
	 chomp;
	 $contig_seq = $_; #store each contig  of the genome file in $contig_seq
	 if ($contig_seq =~ m/($Contig_ID)/i) { #if contig is a match, pull the contig sequence from genome file
	     $CONTIG_HIT = $CONTIG_HIT.">".$contig_seq."\n";
	 }
     }
    }
}

close GENOME;

print "\n\nUnique contigs retrieved and output to 'Contig_Hit_SeqFile.fa'!\n";

#Set output contig seqfile 
my $Contig_Seq_File = $GENOME_ID."_Contig_Hit_SeqFile.fa";


#Output contig sequence file
open my $FILE2, ">", $Contig_Seq_File or die("Can't open file. $!");
print $FILE2 $CONTIG_HIT;
close $FILE2;

exit;
