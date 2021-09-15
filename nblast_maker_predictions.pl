#!/usr/bin/perl 

#------------------------------------------------------------------------------------------------------------------
#ANNOTATE MAKER GENE PREDICTIONS
#Input files are the "_fasta" transcripts, output from cat_maker_files.pl.
#Script will take _maker_transcripts_fasta file and add gene numbers to the maker predictions. Headers will be reformatted to be suitable with blast.
#The re-formatted file will be called GCA123445.1_maker_transcripts.fna (any genome name).
#The genome name is taken directly from the GENOME_maker_transcripts_fasta file, where GENOME is appendix. (This is auto from cat_maker_files.pl)
#The AbInitio gene files will be merged into one file and reformatted as above, with gene numbers starting from last gene number in maker_transcripts.fna file.
#This merged file is called GCA123445.1_Merged_Ab_Initio_Predictions.fna

#Input arguments are:
#ARGV[0] = Primary_reference_file
#ARGV[1] = Secondary_reference_file
#Note the format of these should be >GENE . No other info on headers. This is necessary to annotate maker predictions properly.

#Run blastn against GCA123445.1_maker_transcripts.fna with primary reference.
#Annotate predictions with best hit from primary reference.
#Eg if Gene1 has best hit with >ABL1 in primary reference, then Gene1 will be annotated as ABL1.

#Run blastn against GCA123445.1_maker_transcripts.fna with secondary reference.
#For any annotations in primary reference file that were not assigned a gene, if secondary reference query picks up a hit, it will be annotated.
#Eg. NRXNY is not picked up by primary reference, but is picked up in predictions by secondary reference, then gene will be annotated using secondary reference.

#Important to note: If reference 1 and reference 2 annotate the same gene differently, annotation by primary reference will be prioritised.

#Run blastn against Ab-Initio predictions, with primary reference.
#This will pick up any annotations in primary reference missed in the MAKER predictions file.
#These are assigned asn (AbInitio Prediction) in header, to warn user that these may not be as reliable as (MAKER prediction).
#Ab-Initio predictions are not blasted with secondary reference.

#Output is Annotated_Maker_Predictions directory, which will contain:
#Final_Seq_File.fasta, which includes all the annotated predictions. This is the ultimate output of this script.
#Other summary files are included in subdirectories of Annotated_Maker_Predictions.
#The Annotation summaries are stored in these subdirectories, but also printed to screen while this script is running.
#All blast summary files are also included in subdirectories incase further investigation is needed. 


#------------------------------------------------------------------------------------------------------------------


# 1. Maker transcript predictions
my $Query = $ARGV[0];
my $Alt_Query = $ARGV[1];
my $genome_file_extension = "maker_transcripts_fasta";
my @genome_array = (<*$genome_file_extension>); #Script acs on all .fna files in directory. 


#1.2 Rename Maker transcript predictions to be suitable for blast. Assign arbirtry gene number to each prediction.

foreach my $GENOME(@genome_array){
    open(IN, $GENOME);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; 
    }
    close IN;
    $GENOME =~ s/\_fasta/\.fna/g ;
    my $outfile ="";
    my $newheader="";
    my $head="";
    my $seq="";
    my $gene="";
    my $Head1="";
    my $var = 0;
    my $a = 1;
    if($GENES =~ m/.*?(\.\.\>).*/i) {
	$rm = $1;
	print $rm."\n\n";
	$GENES =~ s/\Q$rm\E//g;
    }
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    $head=">".$1."\n";
	    $seq=$2;
	    $var = $var + $a;
	    $VAR_SAVE = $VAR_SAVE.$var."\n";
	}
	if ($head =~ m/\>(.*)/i) {
	    $Head1 =">Gene".$var." (MAKER prediction) ".$1;
	    chop($Head1);
	}
	if ($Head1 =~ m/\>.*/i){
	    $newheader = $Head1."\n";
	    $outfile=$outfile.$newheader.$seq;
	}
    } 
    open my $NEWFILE, ">", $GENOME or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

#Overwrite array with newly formatted maker_transcripts.fa file:
my $genome_file_extension = "maker_transcripts.fna";
my @genome_array = (<*$genome_file_extension>); #Script acs on all .fna files in directory. 


# 2. AbInitio Predictions (For genes excluded from Maker Output)
my $Augustus_extension = "augustus_masked_transcripts_fasta";
my $Ab_initio_extension = "non_overlapping_ab_initio_transcripts_fasta";
my $Ab_Initio_Merged_extension ="_Merged_Ab_Initio_Predictions.fna";

my @VAR = split("\n", $VAR_SAVE);
my $VAR = pop(@VAR);

my @file_array = (<*$Augustus_extension>);
foreach my $file(@file_array) {
    if ($file =~ m/(GC.*?\_.*?\_)/i) {
	my $genome = $1;
	chop($genome);
	my $out = $genome.$Ab_Initio_Merged_extension;
	my $cmd = "cat $file >> $out";
    print $cmd."\n";
    system("$cmd");
    }
}

my @file_array = (<*$Ab_initio_extension>);
foreach my $file(@file_array) {
    if ($file =~ m/(GC.*?\_.*?\_)/i) {
	my $genome = $1;
	chop($genome);
	my $out = $genome.$Ab_Initio_Merged_extension;
	my $cmd = "cat $file >> $out";
    print $cmd."\n";
    system("$cmd");
    }
}


# 2.1. Rename Ab Initio predictions to be suitable for BLAST. Assign gene neames starting from last number of above numeric scheme (VAR). Add Ab-Initio to gene name to make it clear these are *NOT* maker predictions, rather Ab-inito predictions.

print "\nAssigning gene numbers to maker predictions ....\n";
    
my @file_array = (<*$Ab_Initio_Merged_extension>);
foreach my $file(@file_array){
    open(IN, $file);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; 
    }
    close IN;
    my $outfile ="";
    my $newheader="";
    my $head="";
    my $seq="";
    my $gene="";
    my $Head1="";
    my $a = 1;
    if($GENES =~ m/.*?(\.\.\>).*/i) {
	$rm = $1;
	print $rm."\n\n";
	$GENES =~ s/\Q$rm\E//g;
    }
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    $head=">".$1."\n";
	    $seq=$2;
	    $VAR = $VAR + $a;
	}
	if ($head =~ m/\>(.*)/i) {
	    $Head1 =">Gene".$VAR." (Ab-Initio Prediction) ".$1;
	    chop($Head1);
	}
	if ($Head1 =~ m/\>.*/i){
	    $newheader = $Head1."\n";
	    $outfile=$outfile.$newheader.$seq;
	}
    }
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}



#3. BLAST maker predictions using reference genes as query. Reference gene file is the input argument (ARGV[0])

foreach my $GENOME(@genome_array) {
    #Declare/Reset Variables
    my $Blast_output;
    my $Hit;
    my $Count;
    my $Gene;
    my $Gene_Annotation;
    my $Gene_Annotation_Summary;
    #my $GENE_LIST;
    my $Gene2;
    my $EValue;
    my $Score;
    my $Identity;
    my $Gaps;
    my $Strand;
    my $Gene_Query;
    my $Gene_List;
    my @Gene_array;
    my $Gene_Hit_Summary;
    my $Database;
    my $Gene_check="";
    my $entry_check;
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
	print "-----------------------------------------------------------------------------------------------------";
	print "\n".$makeblastdb_cmd."\n";
	system("$makeblastdb_cmd");
	print "\n".$blastn_cmd."\n";
	system("$blastn_cmd");
	open(BLASTFILE, $out);
	{
	    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
	    $Blast_output = <BLASTFILE>; #Stores contents of BLAST file into a scalor
	}
	my @Blast_array = split("Query\=", $Blast_output); #Splits blast out file  by query chunk
	foreach my $line(@Blast_array) { #Loop over each query chunk
	    $line="Query=".$line; 
	    if ($line =~ m/Query\=\s(.*)\n\nLength/i){
	        $Gene_Query = $1; #Query is "GENE"
		}
		if ($line =~ m/(Database.*?fna)/i) { #storing the database (genome being blasted) info (will be added to sumamry at end)
		    $Database = $1;
		}		    
	    my @gene_array = split(">", $line); #Split each query chunk into gene chunks
	    $Hit = 0;
	    $count = 1;
	    foreach my $gene_chunk(@gene_array) { #Loop over each gene chunk within query chunk
		unless($gene_chunk =~ m/BLASTN\s2\.9\.0\+/ ||  $gene_chunk =~ m/Query\=.*/i) { #Only reappend the > to gene IDs
		    $gene_chunk = ">".$gene_chunk; #Reappend the fasta header to gene chunk
		}
		if ($gene_chunk =~ m/(\>.*?\s)/i) {
		    $Hit = $Hit + $count;
		    if ($Gene_Query !~ m/Database/i) { #RegEx was not specific enough so removing this non-specific hit
			$Gene_Hit_Summary = $Gene_Hit_Summary."\n"."Query= ".$Gene_Query.", "; #Add query info to summary file
		    }
		    $Gene = $1; #Storing Gene Hit identifier
		    $Gene =~ s/\>//;
		    $Gene =~ s/\s//;
		    $Gene = $Gene."split"; #Add split term to identifier. Important for gene check. Removed again later on.
		    if ($Gene !~ m/\s\split/){ 
			#if ($Gene_check !~ m/.*\split$Gene/i && $Gene_check !~ m/$Gene/i) { #If unique gene hit, store to gene list
			   # $Gene_check = $Gene_check.$Gene;
			    #print "\nDoes ".$Hit." equal ".$count."?\n"; #delete this 
			    if ($Hit == $count) {
				$Gene_List = $Gene_List.$Gene;
				$Gene2 = $Gene;
				$Gene2 =~ s/split//;
				$Gene_Annotation = $Gene_Annotation.$Gene_Query."|".$Gene2."\n";
				$Gene_Annotation_Summary = $Gene_Annotation_Summary.$Gene2."\n";
				$GENE_LIST = $GENE_LIST.$Gene_Query."\n";
			    }
			    
		#	}
		    }
		    $Gene =~ s/split//;
		    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene.", "; #Store gene identifier in summary file
		    if ($gene_chunk =~ m/(Score\s\=.*?\,)/i) { 
			$Score = $1; #Store score (bits) info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Score;
		    }
		    if ($gene_chunk =~ m/(Expect\s\=.*[0-9].*e.*[0-9])/i) { 
			$EValue = $1; #Store e-value score info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$EValue.", ";
		    }
		    if ($gene_chunk =~ m/(Identities\s\=.*?\,)/i) { 
			$Identity = $1; #Store Identity score in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Identity;
		    }
		    if ($gene_chunk =~ m/(Gaps\s\=.*?\))/i) {
			$Gaps = $1; #Store Gap info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$Gaps.", ";
		    }
		    if ($gene_chunk =~ m/(Strand\=.*\/.*?\n)/i) { 
			$Strand = $1; #Store strand info in summary file
			$Strand =~ s/\n//;
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Strand;
		    }
		}
	    }
	}
	$Gene_Hit_Summary = "Blast results against ".$Database.":".$Gene_Hit_Summary."\n\n"."Unique gene hits: \n"; #Add database info to summary file.
	@Gene_array = split("\n",$Gene_Annotation); #Split the unique genes into an array. This is where the underscore is important.
	foreach my $Gene_ID (@Gene_array) { #Loop over array and print unique gene list to summary file
	    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene_ID."\n";
	}
	#print $Gene_Hit_Summary."\n\n";
	#print "Annotation Summary: \n";
	#print $Gene_Annotation;
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
	   # print "\n".$Gene_ID."\n";
	    my ($Annotation, $Prediction) = split(/\|/,$Gene_ID, 2);
	   # print "Pulling ".$Prediction." from ".$GENOME."...\n";
	    {local $/ = ">"; #  change line delimter to read in file by gene
	     open(GENOME, $GENOME); #Open the genome file
	     while(<GENOME>) {
		 chomp;
		 $gene_seq = $_; #store each gene  of the genome file in $gene_seq
		 if ($gene_seq =~ m/$Prediction\s\(.*\)(.*)?\n/i) { #if gene is a match, pull the gene sequence from genome file
		     $gene_seq =~ s/\Q$1\E//g; #remove long maker headers
		     $GENE_HIT = $GENE_HIT.">".$Annotation."_".$GENOME_ID."_".$gene_seq."\n";
		 }
	     }
	  }
	}
	close GENOME;
	$Gene_Annotation_Summary =~ s/Gene//g;
	my @GAS = split("\n", $Gene_Annotation_Summary); #Gene Annotation Summary (GAS)
	@GAS_sorted = (sort { $a <=> $b } @GAS); #sort numbers in ascending order
	$Gene_Annotation_Summary = ""; #clear variable for reuse
	foreach my $gn (@GAS_sorted) { #gene (gn) 
	    $Gene_Annotation_Summary = $Gene_Annotation_Summary."Gene".$gn."\n"; #Reappend 'gene' to sorted numbers
	}
	@GAS3 = split("\n", $Gene_Annotation_Summary); #Convert ordered gene list back into an array
	my $Gene_Annotation_Summary = ""; #Clear variable once more for reuse
	foreach my $GN(@GAS3){
	    foreach my $ggnn(@Gene_array){ #ggnn is gene (I'm running out of names ;) )
		if ($ggnn =~ m/(.*)\|$GN$/i){ #Pull annotation and append it to ordered gene list
		    my $ANNOT = $1;
		    my $entry = $GN."|".$ANNOT;
		    #print "Does ".$entry." match ".$entry_check."?\n\n";
		    unless($entry_check =~ m/.*\Q$entry\E\_/i){
			$Gene_Annotation_Summary = $Gene_Annotation_Summary.$entry."\n";
			$entry_check = $entry_check.$entry."_";
		    }
		}
	    }
	}
	$Gene_Annotation_Summary = "Primary reference: ".$Query."\n\nSorted by Gene Number:\n".$Gene_Annotation_Summary; ####
	$Gene_Annotation = "\n\nSorted by Annotation:\n".$Gene_Annotation; #test
	#print $Gene_Annotation."\n";
	my $Summary_File = $GENOME_ID."_Gene_Annotation_Summary.txt";
	open my $SFile, ">", $Summary_File or die("Can't open file. $!");
	print $SFile $Gene_Annotation_Summary;
	print $SFile $Gene_Annotation;
	close $SFile;
	print "\nGenes annotated using primary reference:\n";
	system("cat $Summary_File");
	print "-----------------------------------------------------------------------------------------------------";
	#print "\n\nUnique genes retrieved and output to 'Gene_Hit_SeqFile.fa'!\n";
	my $Gene_Seq_File = $GENOME_ID."_Gene_Hit_SeqFile.fa"; #Output gene sequence file
	open my $FILE2, ">", $Gene_Seq_File or die("Can't open file. $!");
	print $FILE2 $GENE_HIT;
	close $FILE2;
	my $GenDIR= $genome_acession."_Alternative_Reference_Blast_Files";
	system("mkdir $GenDIR");
	system("mv *_File.txt *nhr *nin *nog *nsd *nsi *nsq *out $GenDIR");
    }
}

#print "\n\nGene Query check list:\n";
#print $GENE_LIST."\n\n";


#4. BLAST MAKER predictions with secondary reference

foreach my $GENOME(@genome_array) {
    #Declare/Reset Variables
    my $Blast_output;
    my $Hit;
    my $Count;
    my $Gene;
    my $Gene_Annotation;
    my $Gene_Annotation_Summary;
    #my $GENE_LIST;
    my $Gene2;
    my $EValue;
    my $Score;
    my $Identity;
    my $Gaps;
    my $Strand;
    my $Gene_Query;
    my $Gene_List;
    my @Gene_array;
    my $Gene_Hit_Summary;
    my $Database;
    my $Gene_check="";
    my $entry_check;
    my $GENOME_ID;
    my $gene_seq;
    my $GENE_HIT;
    if ($GENOME =~ m/(GC.*\_.*?\_)/i) {
	my $genome_acession = $1;
	chop($genome_acession);
	my $db = $genome_acession."_blast_DB";
	my $out = $genome_acession."_nblast.out";
	my $makeblastdb_cmd ="makeblastdb -in $GENOME -dbtype nucl -parse_seqids -out $db";
	my $blastn_cmd ="blastn -db $db -query $Alt_Query -out $out";
	print "\n".$makeblastdb_cmd."\n";
	system("$makeblastdb_cmd");
	print "\n".$blastn_cmd."\n";
	system("$blastn_cmd");
	open(BLASTFILE, $out);
	{
	    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
	    $Blast_output = <BLASTFILE>; #Stores contents of BLAST file into a scalor
	}
	my @Blast_array = split("Query\=", $Blast_output); #Splits blast out file  by query chunk
	foreach my $line(@Blast_array) { #Loop over each query chunk
	    $line="Query=".$line; 
	    if ($line =~ m/Query\=\s(.*)\n\nLength/i){
	        $Gene_Query = $1; #Query is "GENE"
		}
		if ($line =~ m/(Database.*?fna)/i) { #storing the database (genome being blasted) info (will be added to sumamry at end)
		    $Database = $1;
		}		    
	    my @gene_array = split(">", $line); #Split each query chunk into gene chunks
	    $Hit = 0;
	    $count = 1;
	    foreach my $gene_chunk(@gene_array) { #Loop over each gene chunk within query chunk
		unless($gene_chunk =~ m/BLASTN\s2\.9\.0\+/ ||  $gene_chunk =~ m/Query\=.*/i) { #Only reappend the > to gene IDs
		    $gene_chunk = ">".$gene_chunk; #Reappend the fasta header to gene chunk
		}
		if ($gene_chunk =~ m/(\>.*?\s)/i) {
		    $Hit = $Hit + $count;
		    if ($Gene_Query !~ m/Database/i) { #RegEx was not specific enough so removing this non-specific hit
			$Gene_Hit_Summary = $Gene_Hit_Summary."\n"."Query= ".$Gene_Query.", "; #Add query info to summary file
		    }
		    $Gene = $1; #Storing Gene Hit identifier
		    $Gene =~ s/\>//;
		    $Gene =~ s/\s//;
		    $Gene = $Gene."split"; #Add split term to identifier. Important for gene check. Removed again later on.
		    if ($Gene !~ m/\s\split/){ 
			if ($GENE_LIST !~ m/.*$Gene_Query\n.*/i) { #If unique gene hit, store to gene list
			    if ($Hit == $count) {
				$Gene_List = $Gene_List.$Gene;
				$Gene2 = $Gene;
				$Gene2 =~ s/split//;
				$Gene_Annotation = $Gene_Annotation.$Gene_Query."|".$Gene2."\n";
				$Gene_Annotation_Summary = $Gene_Annotation_Summary.$Gene2."\n";
				$GENE_LIST = $GENE_LIST.$Gene_Query."\n";
			    }
			    
			}
		    }
		    $Gene =~ s/split//;
		    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene.", "; #Store gene identifier in summary file
		    if ($line =~ m/(Score\s\=.*?\,)/i) {
			$Score = $1; #Store score (bits) info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Score;
		    }
		    if ($line =~ m/(Expect\s\=.*[0-9].*e.*[0-9])/i) {
			$EValue = $1; #Store e-value score info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$EValue.", ";
		    }
		    if ($line =~ m/(Identities\s\=.*?\,)/i) {
			$Identity = $1; #Store Identity score in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Identity;
		    }
		    if ($line =~ m/(Gaps\s\=.*?\))/i) {
			$Gaps = $1; #Store Gap info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$Gaps.", ";
		    }
		    if ($line =~ m/(Strand\=.*\/.*?\n)/i) {
			$Strand = $1; #Store strand info in summary file
			$Strand =~ s/\n//;
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Strand;
		    }
		}
	    }
	}
	$Gene_Hit_Summary = "Blast results against ".$Database.":".$Gene_Hit_Summary."\n\n"."Unique gene hits: \n"; #Add database info to summary file.
	@Gene_array = split("\n",$Gene_Annotation); #Split the unique genes into an array. This is where the underscore is important.
	foreach my $Gene_ID (@Gene_array) { #Loop over array and print unique gene list to summary file
	    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene_ID."\n";
	}
	#print $Gene_Hit_Summary."\n\n";
	#print "Annotation Summary: \n";
	#print $Gene_Annotation;
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
	    #print "\n".$Gene_ID."\n";
	    my ($Annotation, $Prediction) = split(/\|/,$Gene_ID, 2);
	    #print "Pulling ".$Prediction." from ".$GENOME."...\n";
	    {local $/ = ">"; #  change line delimter to read in file by gene
	     open(GENOME, $GENOME); #Open the genome file
	     while(<GENOME>) {
		 chomp;
		 $gene_seq = $_; #store each gene  of the genome file in $gene_seq
		 if ($gene_seq =~ m/$Prediction\s\(.*\)(.*)?\n/i) { #if gene is a match, pull the gene sequence from genome file
		     $gene_seq =~ s/\Q$1\E//g; #remove long maker headers
		     $GENE_HIT = $GENE_HIT.">".$Annotation."_".$GENOME_ID."_".$gene_seq."\n";
		 }
	     }
	  }
	}
	close GENOME;
	$Gene_Annotation_Summary =~ s/Gene//g;
	my @GAS = split("\n", $Gene_Annotation_Summary); #Gene Annotation Summary (GAS)
	@GAS_sorted = (sort { $a <=> $b } @GAS); #sort numbers in ascending order
	$Gene_Annotation_Summary = ""; #clear variable for reuse
	foreach my $gn (@GAS_sorted) { #gene (gn) 
	    $Gene_Annotation_Summary = $Gene_Annotation_Summary."Gene".$gn."\n"; #Reappend 'gene' to sorted numbers
	}
	@GAS3 = split("\n", $Gene_Annotation_Summary); #Convert ordered gene list back into an array
	my $Gene_Annotation_Summary = ""; #Clear variable once more for reuse
	foreach my $GN(@GAS3){
	    foreach my $ggnn(@Gene_array){ #ggnn is gene (I'm running out of names ;) )
		if ($ggnn =~ m/(.*)\|$GN$/i){ #Pull annotation and append it to ordered gene list
		    my $ANNOT = $1;
		    my $entry = $GN."|".$ANNOT;
		    #print "Does ".$entry." match ".$entry_check."?\n\n";
		    unless($entry_check =~ m/.*\Q$entry\E\_/i){
			$Gene_Annotation_Summary = $Gene_Annotation_Summary.$entry."\n";
			$entry_check = $entry_check.$entry."_";
		    }
		}
	    }
	}
	$Gene_Annotation_Summary = "Alternative reference:".$Alt_Query."\n\nSorted by Gene Number:\n".$Gene_Annotation_Summary; ####
	$Gene_Annotation = "\n\nSorted by Annotation:\n".$Gene_Annotation;
	my $Summary_File = $GENOME_ID."_Alternative_Reference_Gene_Annotation_Summary.txt";
	open my $SFile, ">", $Summary_File or die("Can't open file. $!");
	print $SFile $Gene_Annotation_Summary;
	print $SFile $Gene_Annotation;
	close $SFile;
	print "\nAdditional hits picked up by Alternative reference:\n";
	system("cat $Summary_File");
	print "-----------------------------------------------------------------------------------------------------";
	#print "\n\nUnique genes retrieved and output to 'Gene_Hit_SeqFile.fa'!\n";
	my $Gene_Seq_File = $GENOME_ID."_Alternative_Reference_Gene_Hit_SeqFile.fa"; #Output gene sequence file
	open my $FILE2, ">", $Gene_Seq_File or die("Can't open file. $!");
	print $FILE2 $GENE_HIT;
	close $FILE2;
	my $GenDIR= $genome_acession."_Blast_Files";
	system("mkdir $GenDIR");
	system("mv *_File.txt *nhr *nin *nog *nsd *nsi *nsq *out $GenDIR");
    }
}

#print "\n\nGene Query check list:\n";
#print $GENE_LIST."\n\n";




#5. BLAST on abinitio

my @ABINIT_array = (<*$Ab_Initio_Merged_extension>); #Script acs on all .fna files in directory.

foreach my $ABINIT(@ABINIT_array) {
    #Declare/Reset Variables
    my $Blast_output;
    my $entry_check;
    my $Hit;
    my $Count;
    my $Gene;
    my $Gene_Annotation;
    my $Gene_Annotation_Summary;
    my $Gene2;
    my $EValue;
    my $Score;
    my $Identity;
    my $Gaps;
    my $Strand;
    my $Gene_Query;
    my $Gene_List;
    my @Gene_array;
    my $Gene_Hit_Summary;
    my $Database;
    my $Gene_check="";
    my $entry_check;
    my $GENOME_ID;
    my $gene_seq;
    my $GENE_HIT;
    if ($ABINIT =~ m/(.*)\.fna/i) {
	my $prefix = $1;
	my $db = $prefix."_blast_DB";
	my $out = $prefix."_nblast.out";
	my $makeblastdb_cmd ="makeblastdb -in $ABINIT -dbtype nucl -parse_seqids -out $db";
	my $blastn_cmd ="blastn -db $db -query $Query -out $out";
	print "\n".$makeblastdb_cmd."\n";
	system("$makeblastdb_cmd");
	print "\n".$blastn_cmd."\n";
	system("$blastn_cmd");
	open(BLASTFILE, $out);
	{
	    local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
	    $Blast_output = <BLASTFILE>; #Stores contents of BLAST file into a scalor
	}
	my @Blast_array = split("Query\=", $Blast_output); #Splits blast out file  by query chunk
	foreach my $line(@Blast_array) { #Loop over each query chunk
	    $line="Query=".$line; 
	    if ($line =~ m/Query\=\s(.*)\n\nLength/i){
	        $Gene_Query = $1; #Query is "GENE"
		}
		if ($line =~ m/(Database.*?fna)/i) { #storing the database (genome being blasted) info (will be added to sumamry at end)
		    $Database = $1;
		}		    
	    my @gene_array = split(">", $line); #Split each query chunk into gene chunks
	    $Hit = 0;
	    $count = 1;
	    foreach my $gene_chunk(@gene_array) { #Loop over each gene chunk within query chunk
		unless($gene_chunk =~ m/BLASTN\s2\.9\.0\+/ ||  $gene_chunk =~ m/Query\=.*/i) { #Only reappend the > to gene IDs
		    $gene_chunk = ">".$gene_chunk; #Reappend the fasta header to gene chunk
		}
		if ($gene_chunk =~ m/(\>.*?\s)/i) {
		    $Hit = $Hit + $count;
		    if ($Gene_Query !~ m/Database/i) { #RegEx was not specific enough so removing this non-specific hit
			$Gene_Hit_Summary = $Gene_Hit_Summary."\n"."Query= ".$Gene_Query.", "; #Add query info to summary file
		    }
		    $Gene = $1; #Storing Gene Hit identifier
		    $Gene =~ s/\>//;
		    $Gene =~ s/\s//;
		    $Gene = $Gene."split"; #Add split term to identifier. Important for gene check. Removed again later on.
		    if ($Gene !~ m/\s\split/){ 
			if ($GENE_LIST !~ m/.*$Gene_Query\n.*/i) { #If unique gene hit, store to gene list
			    if ($Hit == $count) {
				$Gene_List = $Gene_List.$Gene;
				$Gene2 = $Gene;
				$Gene2 =~ s/split//;
				$Gene_Annotation = $Gene_Annotation.$Gene_Query."|".$Gene2."\n";
				$Gene_Annotation_Summary = $Gene_Annotation_Summary.$Gene2."\n";
				$GENE_LIST = $GENE_LIST.$Gene_Query."\n";
			    }
			    
			}
		    }
		    $Gene =~ s/split//;
		    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene.", "; #Store gene identifier in summary file
		    if ($line =~ m/(Score\s\=.*?\,)/i) {
			$Score = $1; #Store score (bits) info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Score;
		    }
		    if ($line =~ m/(Expect\s\=.*[0-9].*e.*[0-9])/i) {
			$EValue = $1; #Store e-value score info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$EValue.", ";
		    }
		    if ($line =~ m/(Identities\s\=.*?\,)/i) {
			$Identity = $1; #Store Identity score in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Identity;
		    }
		    if ($line =~ m/(Gaps\s\=.*?\))/i) {
			$Gaps = $1; #Store Gap info in summary file
			$Gene_Hit_Summary = $Gene_Hit_Summary." ".$Gaps.", ";
		    }
		    if ($line =~ m/(Strand\=.*\/.*?\n)/i) {
			$Strand = $1; #Store strand info in summary file
			$Strand =~ s/\n//;
			$Gene_Hit_Summary = $Gene_Hit_Summary.$Strand;
		    }
		}
	    }
	}
	$Gene_Hit_Summary = "Blast results against ".$Database.":".$Gene_Hit_Summary."\n\n"."Unique gene hits: \n"; #Add database info to summary file.
	@Gene_array = split("\n",$Gene_Annotation); #Split the unique genes into an array. This is where the underscore is important.
	foreach my $Gene_ID (@Gene_array) { #Loop over array and print unique gene list to summary file
	    $Gene_Hit_Summary = $Gene_Hit_Summary.$Gene_ID."\n";
	}
	#print $Gene_Hit_Summary."\n\n";
	#print "Annotation Summary: \n";
	#print $Gene_Annotation;
	if ($Database =~ m/(GC.*?\_.*)\_Merged/i){ #Getting Genome ID for output file names
	    $GENOME_ACCESSION = $1;
	    $GENOME_ID = $GENOME_ACCESSION."_AbInitio_Predictions";
	}
	my $Gene_Hit_Summary_File = $GENOME_ID."_Gene_Hit_Summary_File.txt"; #Set Summary File name
	open my $FILE1, ">", $Gene_Hit_Summary_File or die("Can't open file. $!"); #Output Summary File
	print $FILE1 $Gene_Hit_Summary;
	close $FILE1;
	close BLASTFILE;
	unless ( open(ABINITFILE, $ABINIT) ) {  #open the file. If it doesnt exist, exit and print an error
	    print "Filename entered does not exist \n ";
	    exit;
	}
	foreach my $Gene_ID(@Gene_array) {
	    #print "\n".$Gene_ID."\n";
	    my ($Annotation, $Prediction) = split(/\|/,$Gene_ID, 2);
	    #print "Pulling ".$Prediction." from ".$ABINIT."...\n";
	    {local $/ = ">"; #  change line delimter to read in file by gene
	     open(ABINITFILE, $ABINIT); #Open the genome file
	     while(<ABINITFILE>) {
		 chomp;
		 $gene_seq = $_; #store each gene  of the genome file in $gene_seq
		 if ($gene_seq =~ m/$Prediction\s\(.*\)(.*)?\n/i) { #if gene is a match, pull the gene sequence from genome file
		     $gene_seq =~ s/\Q$1\E//g; #remove long maker headers
		     $GENE_HIT = $GENE_HIT.">".$Annotation."_".$GENOME_ACCESSION."_".$gene_seq."\n";
		 }
	     }
	  }
	}
	close ABINITFILE;
	$Gene_Annotation_Summary =~ s/Gene//g;
	my @GAS = split("\n", $Gene_Annotation_Summary); #Gene Annotation Summary (GAS)
	@GAS_sorted = (sort { $a <=> $b } @GAS); #sort numbers in ascending order
	$Gene_Annotation_Summary = ""; #clear variable for reuse
	foreach my $gn (@GAS_sorted) { #gene (gn) 
	    $Gene_Annotation_Summary = $Gene_Annotation_Summary."Gene".$gn."\n"; #Reappend 'gene' to sorted numbers
	}
	@GAS3 = split("\n", $Gene_Annotation_Summary); #Convert ordered gene list back into an array
	my $Gene_Annotation_Summary = ""; #Clear variable once more for reuse
	foreach my $GN(@GAS3){
	    foreach my $ggnn(@Gene_array){ #ggnn is gene (I'm running out of names ;) )
		if ($ggnn =~ m/(.*)\|$GN$/i){ #Pull annotation and append it to ordered gene list
		    my $ANNOT = $1;
		    my $entry = $GN."|".$ANNOT;
		    #print "Does ".$entry." match ".$entry_check."?\n\n";
		    unless($entry_check =~ m/.*\Q$entry\E\_/i){
			$Gene_Annotation_Summary = $Gene_Annotation_Summary.$entry."\n";
			$entry_check = $entry_check.$entry."_";
		    }
		}
	    }
	}
	$Gene_Annotation_Summary = "Sorted by Gene Number:\n".$Gene_Annotation_Summary;
	$Gene_Annotation = "\n\nSorted by Annotation:\n".$Gene_Annotation; #test
	#print $Gene_Annotation."\n";
	my $Summary_File = $GENOME_ID."_Gene_Annotation_Summary.txt";
	open my $SFile, ">", $Summary_File or die("Can't open file. $!");
	print $SFile $Gene_Annotation_Summary;
	print $SFile $Gene_Annotation;
	close $SFile;
	print "\nHits not detected in maker output, but detected in AbInitio gene predictions:\n";
	system("cat $Summary_File");
	print "-----------------------------------------------------------------------------------------------------";
	#print "\n\nUnique genes retrieved and output to 'Gene_Hit_SeqFile.fa'!\n";
	my $Gene_Seq_File = $GENOME_ID."_Gene_Hit_SeqFile.fa"; #Output gene sequence file
	open my $FILE2, ">", $Gene_Seq_File or die("Can't open file. $!");
	print $FILE2 $GENE_HIT;
	close $FILE2;
	my $GenDIR= $prefix."_Blast_Files";
	system("mkdir $GenDIR");
	system("mv *_File.txt *nhr *nin *nog *nsd *nsi *nsq *out $GenDIR");
    }
}

#Cat seqfiles to final merged seqfile

print "\n\nAdding ab-initio predictions for query genes with no MAKER prediction to final output file ...\n\n";

$Seqfile = "SeqFile.fa";
my @seqfiles = <*$Seqfile>;
foreach my $f(@seqfiles) {
    #print "\n".$f."\n";
    if ($f =~ m/(GC.*?\_.*?\_)/i) {
	my $GENOME = $1;
	my $final_SEQFILE = $GENOME."Final_SeqFile.fasta";
	my $cmd = "cat ".$f." >> ".$final_SEQFILE;
	print $cmd."\n";
	system("$cmd");
    }
}
	

my $BLASTDIR = "BLAST_Files";
system("mkdir $BLASTDIR");
system("mv *_Blast_Files $BLASTDIR");
my $GENEDIR = "Annotated_Maker_Gene_Predictions";
system("mkdir $GENEDIR");
#system("mv *SeqFile.fa $GENEDIR");
system("mv *SeqFile.fasta $GENEDIR");
my $SUMMARYFILES = "Annotation_Summaries";
system("mkdir $SUMMARYFILES");
system("mv *SeqFile.fa $SUMMARYFILES");
system("mv *Gene_Annotation_Summary.txt $SUMMARYFILES");
system("mv $SUMMARYFILES $GENEDIR");
system("mv $BLASTDIR $GENEDIR");

print "\n\nDone!\nFinal predictions are included in Final_Seq_File.fasta in /Annotated_Maker_Gene_Predictions directory!\n\n";

exit;
