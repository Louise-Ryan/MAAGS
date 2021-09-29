#!/usr/bin/perl -w

## Downlaod genomes.
## Required files in working directory:
## Refseq_assembly_summary text file
## Genbank_assembly_summary text file
## List of query species names as a text file seperated by a new line

## Argument[0] is species list text file
## Argument[1] is prefix for all output directories

## The script will download RefSeq genomes for your species where available. If not available, it will then search for representative genbank genomes.
## If no representative genomes on Genbank, all genbank genomes for that species will be downloaded.

## NOTE: Species names must match EXACTLY what is in the assembly_summary.txt files. If the match isn't exact, the query species will be reported in the
## Genomes_Not_Detected.txt output file.

## Output summary files will be generated for each stage and stored in the LOG_file sub directories

############################################################################################################################################
# Get the RefSeq assembly and Genbank assembly summary files. These are required for this script to work. Can comment this out if you      #
# already have these files, or want to use an older version of these files.                                                                #
############################################################################################################################################

system("wget https://ftp.ncbi.nlm.nih.gov/genomes/genbank/assembly_summary_genbank.txt"); #Genbank summary file
system("wget https://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt"); #RefSeq summary file



############################################################################################################################################
#1. REFSEQ GENOMES                                                                                                                         #
############################################################################################################################################		      		 

#Species file input is first argument 
$species_file_name = $ARGV[0];


#File Prefix as second argument
$Prefix = $ARGV[1];


#Automatically name output files using prefix
my $filtered_refseq_assembly_filename = $Prefix."_filtered_RefSeq_assembly_summary.txt"; #FILE1
my $refseq_genomes_filename = $Prefix."_RefSeq_genomes_summary.txt"; #FILE2
my $Refseq_absent_genomes = $Prefix."_genomes_absent_from_RefSeq.txt"; #FILE3

my $filtered_genbank_rep_assembly_filename = $Prefix."_filtered_rep_GenBank_assembly_summary.txt"; #FILE4
my $genbank_rep_genomes_filename = $Prefix."_GenBank_rep_genomes_summary.txt";  #FILE5
my $Genbank_absent_rep_genomes = $Prefix."_absent_from_genbank_as_representaive_genomes.txt"; #FILE6

my $Filtered_genbank_na_assembly_filename = $Prefix."_filtered_NonRep_Genbank_assembly_summary.txt"; #FILE7
my $genbank_na_present_filename = $Prefix."_GenBank_NonRep_genomes_summary.txt"; #FILE8
my $genbank_absent_filename = $Prefix."_absent_from_GenBank.txt"; #FILE9

		
#Open the file. If it doesnt exist, exit and print an error
unless ( open(SPECIESFILE, $species_file_name) ) {  
     print "Filename entered does not exist \n ";
	exit;
}


#Store the file data as an array
my @target_species_array = <SPECIESFILE>;


#Close the file
close SPECIESFILE;

#Remove empty lines from array
chomp(@target_species_array);

#Declare Variables
my $Filtered_assembly = "";
my $Genomes_found = "";
my $Genomes_not_found = "";


#Loop over each species in target_species_array. Loop over each line in assembly_summary_refseq.txt file. If line in asembly summary matches target species, pull the ftp link for wget. Also pull details for summary files. Three summary files will be generated: 1) a filtered version of assembly summary, 2) RefSeq genome summary, 3)Genomes absent from RefSeq list
foreach my $target(@target_species_array){  
    print "\n\n","Looking for ", $target, "\n";
    open(IN2, "assembly_summary_refseq.txt"); 
    while(<IN2>) {
	my $line=$_; 
	if ($line =~m/genome[\s]+[0-9]+[\s]+[0-9]+[\s]+$target+[\t]/){ #if $line matches "genome +space + numbers + space +target
	    $Filtered_assembly = $Filtered_assembly.$line."\n"; #Store line for filtered assembly
	    if($line=~m/(ftp[\S]+)/){ #Store FTP link (FTP://...link) 
		my $link=$1; 
		if($link=~m/(GCF_+[0-9]+\.[0-9])/){ #Match and store genome acession number for summary files
		    my $accession =$1." "; 
		    $Genomes_found = $Genomes_found.$target."\t".$accession."\n"; #append the target match to genomes found along with the refseq accession number
		    if($link=~m/\/(GCF\_[\S]+)/){ 
			my $file =$1."_genomic.fna.gz"; #Append file extension
			my $final_link = $link."/".$file; #Append file extension and link to ftp link
			system("wget $final_link"); #wget link to download the genome
			sleep(4);
		    }
		}
	    }
	}
    }if ($Genomes_found !~ m/$target+[\t]/){ #if after looping through all lines, there is no match stored in genomes found
	$Genomes_not_found = $Genomes_not_found.$target."\n"; #append the missed species to the genomes_not_found variable
    }
}
	
	
close IN2;

#Output filtered_assembly as a text file
open my $FILE, ">", $filtered_refseq_assembly_filename or die("Can't open file. $!");
print $FILE $Filtered_assembly;
close $FILE;
		
#Output genomes_found as a text file
open my $FILE2, ">", $refseq_genomes_filename or die("Can't open file. $!");
print $FILE2 $Genomes_found;
close $FILE2;

#Output genomes_not_found as a text file
open my $FILE3, ">", $Refseq_absent_genomes or die("Can't open file. $!");
print $FILE3 $Genomes_not_found;
close $FILE3;

#Store RefSeq Genomes in RefSeq_Genomes Directory 
my $RefSeq_Directory = $Prefix."_RefSeq_Genomes";
system("mkdir $RefSeq_Directory");

#Unless there are no GCA files in directory, move all GCA files to GenBank_NonRep_Directory
my @array1=(<GCF*>);
unless (@array1 == 0) {
    system("mv GCF* $RefSeq_Directory");
}



##################################################################################################################################################
# Check point for part 1 to part 2 progression:                                                                                                 ##
##################################################################################################################################################
## Description:															         	##
##																		##
## This script counts the number of genomes present on refseq after running the 'search_refseq_genomes.pl script.        			##
## Takes the output refseq_present text file and the output refseq_absent text file from the search_refseq_genomes.pl script as inputs.	        ##
## Prints total counts for genomes present on reseq, genomes absent on refseq and total genomes.						##
## Total genomes should match the number of query genomes used as input for the 'search_refseq_genomes.pl script.				##
## This section is redundant now unless you want to opt out of pipeline	after any stage (Refseq, genbank rep, genbank nonrep).			##
## UNCOMMENT THIS SECTION IF YOU WANT OPT OUT OPTIONS. TO SUBMIT TO SERVER, LEAVE COMMENTED OUT                                                 ##
##################################################################################################################################################

#my $bell = chr(7); #To warn when first step is done. Checkpoint allows escape after RefSeq download if something seems to have gone wrong.

#my $Total_refseq_present = 0;
#my $Total_refseq_absent = 0; 
#my $Total_species_input = 0;

#Count refseq present:
#unless ( open(REFSEQ_Present, $refseq_genomes_filename) ) {  #open the file. If it doesnt exist, exit and print an error
#     print "Filename entered does not exist \n ";
#	exit;
#}

#Store the file data as an array
#my @refseq_array_present = <REFSEQ_Present>;

#Close the file, Remove empty lines from array
#close REFSEQ_Present;
#chomp(@refseq_array_present); 

#Loop over each element, $target, in @array
#foreach my $species(@refseq_array_present){  
#	$Total_refseq_present = $Total_refseq_present +1 }
       
#Count refseq absent:
#unless ( open(REFSEQ_Absent, $Refseq_absent_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
#     print "Filename entered does not exist \n ";
#	exit;
#}

#Store the file data as an array
#my @refseq_array_absent = <REFSEQ_Absent>;

#Close the file
#close REFSEQ_Absent;

#Remove empty lines from array
#chomp(@refseq_array_absent); 


#Loop over each element, $target, in @array
#foreach my $species(@refseq_array_absent){  
#	$Total_refseq_absent = $Total_refseq_absent +1 }


#Count total number of input species
#foreach my $species(@target_species_array) {
#	$Total_species_input = $Total_species_input +1 }

#my $Total_genomes = $Total_refseq_present + $Total_refseq_absent;

#Print outs 
#print "\n","\n", "Checkpoint 1: Counting genomes... \n";
#print "Total genomes present on refseq:", "\n", $Total_refseq_present, "\n";	
#print "Total genomes absent on refseq:", "\n", $Total_refseq_absent, "\n";
#print "Total genomes:", "\n", $Total_genomes, "\n";
#print "Total query species:", "\n", $Total_species_input, "\n";

#Warning message
#if ($Total_species_input != $Total_genomes) {
#    print $bell;
#    print "Total genomes searched ", "(", $Total_genomes, ")",  " is not equal to total query species ", "(", $Total_species_input, ")", "\n";
#    print "Somthing may have gone wrong, Do you still want to continue to downloading genbank genomes? (Yes/No):";
#    my $Yes_No = <STDIN>;
#    chomp($Yes_No);
#    unless ($Yes_No =~ /^[Yes|yes|Y|y]$/) {
#	exit;
#    }
#}

#All clear message
#if ($Total_species_input == $Total_genomes) {
#    print $bell;
#    print "Total genomes searched ", "(", $Total_genomes, ")",  " is equal to total query species ", "(", $Total_species_input, ")", "\n";
#    print "Everything looks good. Do you want to continue to downloading genbank genomes? (Yes/No):";
#    my $Yes_No = <STDIN>;
#    chomp($Yes_No);
#    if ($Yes_No =~ /^Yes|yes|Y|y$/) {
#	print "\n","\n","Proceeding to genbank downloads...","\n\n";
#    }else{
#	print "exiting pipeline...","\n\n";
#	exit;
#    }
#}


#########################################################################################################################################	
#2. Representative GENBANK GENOMES:                                                                                                    ##
#########################################################################################################################################

#Open the file. If it doesnt exist, exit and print an error
unless ( open(SPECIESFILE2, $Refseq_absent_genomes) ) {  
     print "Filename entered does not exist \n ";
	exit;
}

#Store the file data as an array
my @target_genbank_species_array = <SPECIESFILE2>;

#Close the file
close SPECIESFILE2;

#Remove empty lines from array
chomp(@target_genbank_species_array); 

#Declare variables
my $genbank_rep_genomes_found = "";
my $genbank_rep_genomes_absent = "";
my $Filtered_genbank_rep_assembly = "";


#Loop over each target in the RefSeq absent file, and look for a target match with line in assembly_summary_genbank.txt file. Only spcies with no ReSeq genome will be downloaded.
#Only representative genbank genomes downloaded in this chunk. Species with no representaive genbank or refseq assembly will be dealth with in next chunk.

foreach my $target2(@target_genbank_species_array){
    print "\n\n","Looking for ", $target2, "\n";
    open(IN3, "assembly_summary_genbank.txt");
    while(<IN3>) { #Loop through the assembly_summary text file
	my $line2=$_; 
	#unless($line2 =~m/strain/) {
	unless ($line2 =~m/virus/) { #don't download viral or isolate genomes. This avoids download of microorganism genomes sampled from the target species.
	    unless ($line2 =~m/isolate/){
		if ($line2 =~m/genome[\s]+[0-9]+[\s]+[0-9]+[\s]+$target2+[\t]/){ #if $line2 matches genome +space + numbers + space +target2
		    $Filtered_genbank_rep_assembly = $Filtered_genbank_rep_assembly.$line2."\n"; #store line in filtered assembly
		    if($line2=~m/(ftp[\S]+)/){ #Match and and store FTP link
			my $link2=$1;
			if($link2=~m/(GCA_+[0-9]+\.[0-9])/){ #Store GCA accession
			    my $genbank_accession =$1." "; 
			    $genbank_rep_genomes_found = $genbank_rep_genomes_found.$target2."\t".$genbank_accession."\n"; #append the target match to genomes found along with the refseq accession number
			    if($link2=~m/\/(GCA\_[\S]+)/){ 
				my $file2 =$1. "_genomic.fna.gz"; #Append genome file extension
				my $final_link2 = $link2."/".$file2; #Append genome file link to ftp link
				system("wget $final_link2"); #wget link to download the genome
				sleep(4);
			    }
			}
		    }
		}
	    }
	}
    }if ($genbank_rep_genomes_found !~ m/$target2+[\t]/){ #if after looping through all lines, there is no match stored in genomes found
	$genbank_rep_genomes_absent = $genbank_rep_genomes_absent.$target2."\n"; #append the miss species to the genomes_not_found variable
    }
}
	
	
close IN3;


#Output filtered_assembly as a text file
open my $FILE4, ">", $filtered_genbank_rep_assembly_filename or die("Can't open file. $!");
print $FILE4 $Filtered_genbank_rep_assembly;
close $FILE4;
		
#Output genomes_found as a text file
open my $FILE5, ">", $genbank_rep_genomes_filename or die("Can't open file. $!");
print $FILE5 $genbank_rep_genomes_found;
close $FILE5;

#Output genomes_not_found as a text file
open my $FILE6, ">", $Genbank_absent_rep_genomes or die("Can't open file. $!");
print $FILE6 $genbank_rep_genomes_absent;
close $FILE6;

#Store RefSeq Genomes in RefSeq_Genomes Directory 
my $GenBank_Rep_Directory = $Prefix."_GenBank_Rep_Genomes";
system("mkdir $GenBank_Rep_Directory");

#Unless no GCA files in directory, move al GCA files to GenBank_Rep_Directory
my @array2=(<GCA*>);
unless (@array2 == 0) {
    system("mv GCA* $GenBank_Rep_Directory");
}



##################################################################################################################################################
# Count Check point for part 2 to part 3 progression:                                                                                           ##
##################################################################################################################################################
## Total genomes should match the number of query genomes used as input for the 'search_refseq_genomes.pl script.				##
## This section is redundant now unless you want to opt out of pipeline	after any stage (Refseq, genbank rep, genbank nonrep).			##
## UNCOMMENT THIS SECTION IF YOU WANT OPT OUT OPTIONS. TO SUBMIT TO SERVER, LEAVE COMMENTED OUT                                                 ##
##################################################################################################################################################

#my $Total_genbank_rep_present = 0;
#my $Total_genbank_rep_absent = 0; 
#my $Total_genbank_species_input = 0;


#Count refseq present:
#unless ( open(GENBANK_REP_Present, $genbank_rep_genomes_filename) ) {  #open the file. If it doesnt exist, exit and print an error
#     print "Filename entered does not exist \n ";
#	exit;
#}

#Store the file data as an array
#my @GENBANK_rep_array_present = <GENBANK_REP_Present>;

#Close the file
#close GENBANK_REP_Present;

#Remove empty lines from array
#chomp(@GENBANK_rep_array_present); 

#Loop over each element, $target, in @array
#foreach my $species(@GENBANK_rep_array_present){ 
#	$Total_genbank_rep_present = $Total_genbank_rep_present +1 }

#Count refseq absent:
#unless ( open(GENBANK_REP_Absent, $Genbank_absent_rep_genomes) ) {  
#     print "Filename entered does not exist \n ";
#	exit;
#}

#Store the file data as an array
#my @GENBANK_rep_array_absent = <GENBANK_REP_Absent>;

#Close the file
#close GENBANK_REP_Absent;

#Remove empty lines from array
#chomp(@GENBANK_rep_array_absent); 

#Loop over each element, $target, in @array
#foreach my $species(@GENBANK_rep_array_absent){  
#	$Total_genbank_rep_absent = $Total_genbank_rep_absent +1 }


#Count total number of input species
#foreach my $species(@target_genbank_species_array) {
#	$Total_genbank_species_input = $Total_genbank_species_input +1 }

#my $Total_genbank_genomes = $Total_genbank_rep_present + $Total_genbank_rep_absent;

#Printouts
#print "\n","\n", "Checkpoint 1: Counting genomes...\n";
#print "Total representative genomes present on genbank:", "\n", $Total_genbank_rep_present, "\n";	
#print "Total genomes with no representative genome on genbank:", "\n", $Total_genbank_rep_absent, "\n";
#print "Total genomes searched:", "\n", $Total_genbank_genomes, "\n";
#print "Total query species:", "\n", $Total_genbank_species_input, "\n";

#Warning Printout..opt out option
#if ($Total_genbank_species_input != $Total_genbank_genomes) {
#    print $bell;
#    print "Total genomes searched ", "(", $Total_genbank_genomes, ")",  " is not equal to total query species ", "(", $Total_genbank_species_input, ")", "\n";
#    print "Somthing may have gone wrong, Do you still want to continue to downloading genbank genomes? (Yes/No):";
#    my $Yes_No2 = <STDIN>;
#    chomp($Yes_No2);
#    unless ($Yes_No2 =~ /^[Yes|yes|Y|y]$/) {
#	exit;
#    }
#}

#All clear printout ..opt out option
#if ($Total_genbank_species_input == $Total_genbank_genomes) {
#    print $bell;
#    print "Total genomes searched ", "(", $Total_genbank_genomes, ")",  " is equal to total query species ", "(", $Total_genbank_species_input, ")", "\n";
#    print "Everything looks good. Do you want to continue to downloading genbank non-representative genomes? (Yes/No):";
#    my $Yes_No2 = <STDIN>;
#    chomp($Yes_No2);
#    if ($Yes_No2 =~ /^Yes|yes|Y|y$/) {
#	print "\n","\n","Proceeding to genbank non-representative genome downloads...","\n\n";
#    }else{
#	print "exiting pipeline...","\n\n";
#	exit;
#    }
#}


#########################################################################################################################################	
#3. Non-Representative GENBANK GENOMES:                                                                                                ##
#########################################################################################################################################

#open the file. If it doesnt exist, exit and print an erro
unless ( open(SPECIESFILE, $Genbank_absent_rep_genomes) ) {  
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @genbank_na_array = <SPECIESFILE>;

#close the file
close SPECIESFILE;

# remove empty lines from array
chomp(@genbank_na_array); 


my $genbank_na_genomes_found = "";
my $genbank_na_genomes_absent = ""; ##this should be zero unless somthing went wrong
my $Filtered_genbank_na_assembly = "";



foreach my $target3(@genbank_na_array){  #Loop over each element, $target, in @array
    print "Looking for ", $target3. "\n";
    open(IN4, "assembly_summary_genbank.txt"); #open the assembly_summary text file, file handle = IN
    while(<IN4>) {
	my $line3=$_; #store each line of the text file in $line3
	#unless($line3 =~m/strain/) {
	unless ($line3 =~m/virus/) {
	    unless ($line3 =~m/isolate/){
		if ($line3 =~m/[na|genome]+[\s]+[0-9]+[\s]+[0-9]+[\s]+$target3+[\t]/){ #if $line3 matches "genome +space + numbers + space +target
		    $Filtered_genbank_na_assembly = $Filtered_genbank_na_assembly.$line3."\n"; 
		    if($line3=~m/(ftp[\S]+)/){ #Match and store FTP link
			my $link3=$1;
			if($link3=~m/(GCA_+[0-9]+\.[0-9])/){ #Pull and store genome acession
			    my $accession3 =$1." "; 
			    $genbank_na_genomes_found = $genbank_na_genomes_found.$target3."\t".$accession3."\n"; #append the target match to genomes found along with the refseq accession number
			    if($link3=~m/\/(GCA\_[\S]+)/){ 
				my $file3 =$1. "_genomic.fna.gz"; #Genome file extension
				my $final_link3 = $link3."/".$file3; #Append genome file extension and link to FTP link
				system("wget $final_link3"); #wget link to download the genome
				sleep(4);
			    } 
		       	}
		    }
		}
	    }
	}
	#} only needed if the unless strain statement is uncommented above.
    }if ($genbank_na_genomes_found !~ m/$target3+[\t]/){ #if after looping through all lines, there is no match stored in genomes found
	$genbank_na_genomes_absent = $genbank_na_genomes_absent.$target3."\n"; #append the miss species to the genomes_not_found variable
    }
}
		
close IN4;
		
#Output filtered_assembly as a text file
open my $FILE9, ">", $Filtered_genbank_na_assembly_filename or die("Can't open file. $!");
print $FILE9 $Filtered_genbank_na_assembly;
close $FILE9;		
		
		
#Output genomes_found as a text file
open my $FILE7, ">", $genbank_na_present_filename or die("Can't open file. $!");
print $FILE7 $genbank_na_genomes_found;
close $FILE7;

#Output genomes_not_found as a text file
open my $FILE8, ">", $genbank_absent_filename or die("Can't open file. $!");
print $FILE8 $genbank_na_genomes_absent;
close $FILE8;

#Store RefSeq Genomes in RefSeq_Genomes Directory 
my $GenBank_NonRep_Directory = $Prefix."_GenBank_non_rep_Genomes";
system("mkdir $GenBank_NonRep_Directory");

#Unless there are no GCA files in directory, move all GCA files to GenBank_NonRep_Directory
my @array3=(<GCA*>);
unless (@array == 0) {
    system("mv GCA* $GenBank_NonRep_Directory");
}


#########################################################################################################################################	
#4.Output files and tidy into directories                                                                                              ##
#########################################################################################################################################


#RefSeq Sub Directory for LOG files

my $RefSeq_log_sub_Directory = $RefSeq_Directory."/LOG_files";
system("mkdir $RefSeq_log_sub_Directory");
system("mv $filtered_refseq_assembly_filename $refseq_genomes_filename $Refseq_absent_genomes $RefSeq_log_sub_Directory");

#GenBank Representative Genomes Sub Directory for LOG files
my $GenBank_rep_log_sub_Directory = $GenBank_Rep_Directory."/LOG_files";
system("mkdir $GenBank_rep_log_sub_Directory");
system("mv $filtered_genbank_rep_assembly_filename $genbank_rep_genomes_filename $Genbank_absent_rep_genomes $GenBank_rep_log_sub_Directory");

#GenBank Non Representative Genomes Sub Directory for LOG files
my $GenBank_NonRep_log_sub_Directory= $GenBank_NonRep_Directory."/LOG_files";
system("mkdir $GenBank_NonRep_log_sub_Directory");
my $Absent_from_NCBI_filename = $Prefix."_Genomes_Not_Detected.txt";
system("cp $genbank_absent_filename $Absent_from_NCBI_filename");
system("mv $Filtered_genbank_na_assembly_filename $genbank_na_present_filename $genbank_absent_filename $GenBank_NonRep_log_sub_Directory");

#Directory for all output files
my $OutDirectory = $Prefix."_Output_Genome_files";
system("mkdir $OutDirectory");
system("mv $RefSeq_Directory $GenBank_Rep_Directory $GenBank_NonRep_Directory $Absent_from_NCBI_filename $OutDirectory");

exit;  











