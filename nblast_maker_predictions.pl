#!/usr/bin/perl 

#------------------------------------------------------------------------------------------------------------------
#PULL GENE PREDICTIONS FROM blastn OUTFILE
#loop over each genome in directory and makeblastdb.
#Run blastn against each genome db using query sequences. Query sequences can be multiple genes from multiple species in one input query fa seqfile.
#Generate blast results out file for each species
#parse blastn output file for each species.
#Pull gene hit name and store in an array. Only store unique hits where genes from multiple species are used as blastn input.
#All genes with a hit will be pulled regardless of signifigance scores.
#hence if query hits 2 genes, both are pulled, not just most signifigant one.
#Pull scores and gene info and stores in Gene_Hit_Summary.txt.
#Opens Genome file and pulls unique genes from the target genome and stores in Gene_Hit_SeqFile.fa.
#Run this script on one blast output file corresponding to one target genome at a time.
#Can handle multiple genes from multiple species as blast query against target genome.

#WARNING: Make sure no stray fasta header symbols (>) in query. Carlito syrichta fasta headers include an unecessary stray > in description. These need to be removed prior to this script!

#ARGV0=Query seq file


#------------------------------------------------------------------------------------------------------------------

# 1. makeblastdb and nblast  on all genomes in directory using query seqfile
my $Query = $ARGV[0];
my $genome_file_extension = ".fna";
my @genome_array = (<*$genome_file_extension>); #Script acs on all .fna files in directory. 



foreach my $GENOME(@genome_array) {
    #Declare/Reset Variables
    my $Blast_output;
    my $Gene;
    my $Gene_List;
    my @Gene_array;
    my $Gene_Hit_Summary;
    my $Database;
    my $Gene_check="";
    my $GENOME_ID;
    my $gene_seq;
    my $GENE_HIT;
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
	my @Blast_array = split("Query\=", $Blast_output); #Splits blast out file  by query chunk
	foreach my $line(@Blast_array) { #Loop over each query chunk
	    $line="Query=".$line; 
	    if ($line =~ m/(Query\=\s(.*)\n)/i){  
		my $Gene_Query = $1; #Query is "GENE" 
		}
		if ($line =~ m/(Database.*?fna)/i) { #storing the database (genome being blasted) info (will be added to sumamry at end)
		    $Database = $1;
		}		    
		my @gene_array = split(">", $line); #Split each query chunk into gene chunks 
		foreach my $gene_chunk(@gene_array) { #Loop over each gene chunk within query chunk
		    unless($gene_chunk =~ m/BLASTN\s2\.9\.0\+/ ||  $gene_chunk =~ m/Query\=.*/i) { #Only reappend the > to gene IDs
			$gene_chunk = ">".$gene_chunk; #Reappend the fasta header to gene chunk
		    }
		    if ($gene_chunk =~ m/(\>.*?\s)/i) { 
			if ($Gene_Query !~ m/Database/i) { #RegEx was not specific enough so removing this non-specific hit
			    $Gene_Hit_Summary = $Gene_Hit_Summary."\n"."Query Gene = ".$Gene_Query.", "; #Add query info to summary file
			}
			$Gene = $1; #Storing Gene Hit identifier
			$Gene =~ s/\>//;
			$Gene =~ s/\s//;
			$Gene = $Gene."split"; #Add split term to identifier. Important for gene check. Removed again later on.
			if ($Gene !~ m/\s\split/){ 
			    if ($Gene_check !~ m/.*\split$Gene/i && $Gene_check !~ m/$Gene/i) { #If unique gene hit, store to gene list
				$Gene_check = $Gene_check.$Gene;
				#print "\n\nGene: ".$Gene."\nGene Check: ".$Gene_check."\n\n"; #can comment this out
				$Gene_List = $Gene_List.$Gene
			    }
			}
			$Gene =~ s/split//;
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Gene; #Store gene identifier in summary file
			}
		}
	}
	$Gene_Hit_Summary = "Blast results against ".$Database.":".$Gene_Hit_Summary."\n\n"."Unique gene hits: \n"; #Add database info to summary file.
	@Gene_array = split("split",$Gene_List); #Split the unique genes into an array. This is where the underscore is important.
	foreach my $Gene_ID (@Gene_array) { #Loop over array and print unique gene list to summary file
	    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene_ID."\n";
	}
	print $Gene_Hit_Summary."\n\n";
	if ($Database =~ m/(GC.*?\_.*?\_)/i){ #Getting Genome ID for output file names
	    $GENOME_ID = $1;
	    chop($GENOME_ID);
	}
	my $Gene_Hit_Summary_File = $GENOME_ID."_Gene_Hit_Summary_File.txt"; #Set Summary File name
	open my $FILE1, ">", $Gene_Hit_Summary_File or die("Can't open file. $!"); #Output Summary File
	print $FILE1 $Gene_Hit_Summary;
	close $FILE1;
	close BLASTFILE;
	unless ( open(GENOME, $GENOME) ) {  #open the file. If it doesnt exist, exit and print an error
	    print "Filename entered does not exist \n ";
	    exit;
	}
	foreach my $Gene_ID(@Gene_array) {
	    print "Pulling ".$Gene_ID." from ".$GENOME."...\n";
	    {local $/ = ">"; #  change line delimter to read in file by gene
	     open(GENOME, $GENOME); #Open the genome file
	     while(<GENOME>) {
		 chomp;
		 $gene_seq = $_; #store each gene  of the genome file in $gene_seq
		 if ($gene_seq =~ m/($Gene_ID)/i) { #if gene is a match, pull the gene sequence from genome file
		     $GENE_HIT = $GENE_HIT.">".$gene_seq."\n";
		 }
	     }
	    }
	}
	close GENOME;
	print "\n\nUnique genes retrieved and output to 'Gene_Hit_SeqFile.fa'!\n";
	my $Gene_Seq_File = $GENOME_ID."_Gene_Hit_SeqFile.fa"; #Output gene sequence file
	open my $FILE2, ">", $Gene_Seq_File or die("Can't open file. $!");
	print $FILE2 $GENE_HIT;
	close $FILE2;
	my $GenDIR= $genome_acession."_Blast_Files";
	system("mkdir $GenDIR");
	system("mv *_File.txt *nhr *nin *nog *nsd *nsi *nsq *out $GenDIR");
    }
}
my $BLASTDIR = "BLAST_Files";
system("mkdir $BLASTDIR");
system("mv *_Blast_Files $BLASTDIR");
my $GENEDIR = "Gene_Hit_SeqFiles";
system("mkdir $GENEDIR");
system("mv *Gene_Hit_SeqFile.fa $GENEDIR");
system("mv $BLASTDIR $GENEDIR");

exit;