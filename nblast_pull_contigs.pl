#!/usr/bin/perl 

#------------------------------------------------------------------------------------------------------------------
#PULL CONTIGS FROM blastn OUTFILE
#loop over each genome in directory and makeblastdb.
#Run blastn against each genome db using query sequences. Query sequences can be multiple genes from multiple species in one input query fa seqfile.
#Generate blast results out file for each species
#parse blastn output file for each species.
#Pull contig hit name and store in an array. Only store unique hits where genes from multiple species are used as blastn input.
#Pull scores and contig info and stores in Contig_Hit_Summary.txt.
#Opens Genome file and pulls unique contigs from the target genome and stores in Contig_Hit_SeqFile.fa.
#Run this script on one blast output file corresponding to one target genome at a time.
#Can handle multiple genes from multiple species as blast query against target genome.

#ARGV0=Blast output file name
#ARGV1=Target Genome


#------------------------------------------------------------------------------------------------------------------

# 1. makeblastdb and nblast  on all genomes in directory using query seqfile
my $Query = $ARGV[0];
my $genome_file_extension = ".fna";
my @genome_array = (<*$genome_file_extension>);



foreach my $GENOME(@genome_array) {
    #Declare/Reset Variables
    my $Blast_output;
    my $Contig;
    my $EValue;
    my $Score;
    my $Identity;
    my $Gaps;
    my $Strand;
    my $Contig_List;
    my @Contig_array;
    my $Contig_Hit_Summary;
    my $Database;
    my $Contig_check="";
    my $GENOME_ID;
    my $contig_seq;
    my $CONTIG_HIT;
    if ($GENOME =~ m/(GC.*\_.*?\_)/i) {
	my $genome_acession = $1;
	chop($genome_acession);
	my $db = $genome_acession."_blast_DB";
	my $out = $genome_acession."_nblast.out";
	my $makeblastdb_cmd ="makeblastdb -in $GENOME -dbtype nucl -parse_seqids -out $db";
	my $blastn_cmd ="blastn -db $db -query $Query -out $out";
	print "\n".$makeblastdb_cmd."\n";
	system("$makeblastdb_cmd");
	print "\n\n".$blastn_cmd."\n\n";
	system("$blastn_cmd");
	open(BLASTFILE, $out);
	{
	    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
	    $Blast_output = <BLASTFILE>; #Stores contents of BLAST file into a scalor
	}
	my @Blast_array = split("Query\=", $Blast_output); #Splits by query and stores each query as an element of the array that can be looped over
	foreach my $line(@Blast_array) { #each query chunk is stored in $line from blast output file # print $line."\n";
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
		    if ($Contig_check !~ m/.*\_$Contig/i && $Contig_check !~ m/$Contig/i) { #If unique contig hit, store to contig list
			$Contig_check = $Contig_check.$Contig;
			print "\n\nContig: ".$Contig."\nContig Check: ".$Contig_check."\n\n";
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
	if ($Database =~ m/(GC.*?\_.*?\_)/i){ #Getting Genome ID for output file names
	    $GENOME_ID = $1;
	    chop($GENOME_ID);
	}
	my $Contig_Hit_Summary_File = $GENOME_ID."_Contig_Hit_Summary_File.txt"; #Set Summary File name
	open my $FILE1, ">", $Contig_Hit_Summary_File or die("Can't open file. $!"); #Output Summary File
	print $FILE1 $Contig_Hit_Summary;
	close $FILE1;
	close BLASTFILE;
	unless ( open(GENOME, $GENOME) ) {  #open the file. If it doesnt exist, exit and print an error
	    print "Filename entered does not exist \n ";
	    exit;
	}
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
	my $Contig_Seq_File = $GENOME_ID."_Contig_Hit_SeqFile.fa"; #Output contig sequence file
	open my $FILE2, ">", $Contig_Seq_File or die("Can't open file. $!");
	print $FILE2 $CONTIG_HIT;
	close $FILE2;
	my $GenDIR= $genome_acession."_Blast_Files";
	system("mkdir $GenDIR");
	system("mv *_File.txt *nhr *nin *nog *nsd *nsi *nsq *out $GenDIR");
    }
   
}
my $BLASTDIR = "BLAST_Files";
system("mkdir $BLASTDIR");
system("mv *_Blast_Files $BLASTDIR");
my $CONTIGDIR = "Contig_Hit_SeqFiles";
system("mkdir $CONTIGDIR");
system("mv *Contig_Hit_SeqFile.fa $CONTIGDIR");
system("mv $BLASTDIR $CONTIGDIR");

exit;
