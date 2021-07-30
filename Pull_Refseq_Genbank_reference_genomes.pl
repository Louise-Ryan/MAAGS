#!/usr/bin/perl -w



##Downlaod genomes:
# Required files in working directory:
# Refseq_assembly_summary text file
# Genbank_assembly_summary text file
# List of query species names as a text file seperated by a new line
#
#The script will download RefSeq genomes for your species where available. If not available, it will then search for representative genbank genomes.
# If no representative genomes on Genbank, all genbank genomes for that species will be downloaded. 

#Output summary files will be generated for each stage


#1. REFSEQ GENOMES
#######################################################################################################################
# Search the refseq assembly file for target genomes. Output the refseq assembly summary details for target species with genomes on refseq.
# For species with a genome on refseq, list these with their accession number in a text file.
# Also list species not available on refseq in a seperate text file.
# Download all available refseq genomes

######################################################################################################################
## Description filter assembly:											 ##
## Use this sript to search the assembly_summary_refseq.txt file for specific genomes. Output a filtered  		 ##
## version of the assembly_summary file containing just your query species. Input is species text file    		 ##
## where each species is listed on a new line in the text file. Output is filtered assembly text file.    		 ##
##															 ##
## Description search genomes:									     		 ##
## Use this sript to search the assembly_summary_refseq.txt file for specific genomes. If the genome in   		 ##
## your list gets a hit, it will be listed in an output file. If the genome in your list is not on refseq 		 ##
## it will be listed in a seperate output file. Input species file must be a text file with each query    		 ##
## species listed on a new line in the text file. This script also retrives the refseq accession number   		 ##
##for each genome and adds this to the ref_seq present text files.					      		 ##
##													      		 ##
## NOTE: Canis lupus will match with both 'Canis lupis' and Canis lupis familiaris'. 		      		 ##
## Hence three canis lupus matches will be found, where canis lupis familiaris is repeated twice	      		 ##
## Wasn't sure how to fix this.											 ##
##													      		 ##
## Descripion pull genomes:												 ##
## This script searches the assembly_summary_refseq.txt file for genomes that are present on ref_seq.		 ##
## Input is a text file containing a list of query species, with each query species on a new line in the txt file	 ##
## Once query species is found, script will use wget to download this refseq genome to the working directory.	 ##
## Hence, script searches for and downloads all query species that are available on refseq.				 ##
#######################################################################################################################

#ask for text file with species names and store the string as species_file_name 
#print "Enter title of text file containing target species names:";
#$species_file_name = <STDIN>;
#chomp $species_file_name;

#Species file input is first argument 
$species_file_name = $ARGV[0];


##ask for text file with species names and store the string as species_file_name 
print "Enter prefix for naming all output directories and files:";
my $Prefix = <STDIN>;
chomp $Prefix;


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

		
#open the file. If it doesnt exist, exit and print an error
unless ( open(SPECIESFILE, $species_file_name) ) {  
     print "Filename entered does not exist \n ";
	exit;
}


#store the file data as an array
my @target_species_array = <SPECIESFILE>;

#close the file
close SPECIESFILE;

chomp(@target_species_array); # remove empty lines from array



my $Filtered_assembly = "";
my $Genomes_found = "";
my $Genomes_not_found = "";


foreach my $target(@target_species_array){  #Loop over each element, $target, in @array
    print "\n\n","Looking for ", $target, "\n";
    open(IN2, "assembly_summary_refseq.txt"); #open the assembly_summary text file, file handle = IN
	while(<IN2>) { 
	my $line=$_; #store each line of the text file in $line
   		if ($line =~m/genome[\s]+[0-9]+[\s]+[0-9]+[\s]+$target/){ #if $line matches "genome +space + numbers + space +target
   		$Filtered_assembly = $Filtered_assembly.$line."\n"; #store line in filtered assembly
			if($line=~m/(ftp[\S]+)/){ #if this line has ftp followed by anything (FTP://...link) take this and store it as link
	    		my $link=$1;#create variable link and store the FTP link
	    			if($link=~m/(GCF_+[0-9]+\.[0-9])/){ #we want to take the GCF accession from the link and store it as accession 
				my $accession =$1." "; #save the accession which matched the regex above
				$Genomes_found = $Genomes_found.$target." ".$accession."\n"; #append the target match to genomes found along with the refseq accession number
	    				if($link=~m/\/(GCF\_[\S]+)/){ #we want to take the \GCF part of the FTP link and repeat it by appending it to the FTP link (see link we want)  
					my $file =$1. "_genomic.fna.gz"; #we still need to append  _genomic.fna.gz to get the full genome link (link we want)
					my $final_link = $link."/".$file; #final step to get link: append GCF_000001405.39_GRCh38.p13_genomic.fna.gz to the FTP link seperated by / 
					system("wget $final_link"); #wget link to download the genome
							} 
						}
					}
				}
			}if ($Genomes_found !~ m/$target/){ #if after looping through all lines, there is no match stored in genomes found
			$Genomes_not_found = $Genomes_not_found.$target."\n"; #append the miss species to the genomes_not_found variable
		}
	}
	
	
close IN2;

my $bell = chr(7);
print $bell;

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
system("mv GCF* $RefSeq_Directory");

########################################################################################################################

# Check point for part 1-part 2 progression:

#############################################################################################################################################
## Description:																##
##																		##
## This script counts the number of genomes present on refseq after running the 'search_refseq_genomes.pl script.        			##
## Takes the output refseq_present text file and the output refseq_absent text file from the search_refseq_genomes.pl script as inputs.	##
## Prints total counts for genomes present on reseq, genomes absent on refseq and total genomes.						##
## Total genomes should match the number of query genomes used as input for the 'search_refseq_genomes.pl script.				##
##																		##
#############################################################################################################################################


my $Total_refseq_present = 0;
my $Total_refseq_absent = 0; 
my $Total_species_input = 0;


####count refseq present:

unless ( open(REFSEQ_Present, $refseq_genomes_filename) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @refseq_array_present = <REFSEQ_Present>;

#close the file
close REFSEQ_Present;

chomp(@refseq_array_present); # remove empty lines from array


foreach my $species(@refseq_array_present){  #Loop over each element, $target, in @array
	$Total_refseq_present = $Total_refseq_present +1 }
	


###count refseq absent:

unless ( open(REFSEQ_Absent, $Refseq_absent_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @refseq_array_absent = <REFSEQ_Absent>;

#close the file
close REFSEQ_Absent;

chomp(@refseq_array_absent); # remove empty lines from array


foreach my $species(@refseq_array_absent){  #Loop over each element, $target, in @array
	$Total_refseq_absent = $Total_refseq_absent +1 }


# Count total number of input species

foreach my $species(@target_species_array) {
	$Total_species_input = $Total_species_input +1 }

my $Total_genomes = $Total_refseq_present + $Total_refseq_absent;

print "\n","\n", "Checkpoint 1: Counting genomes";
print "Total genomes present on refseq:", "\n", $Total_refseq_present, "\n";	
print "Total genomes absent on refseq:", "\n", $Total_refseq_absent, "\n";
print "Total genomes:", "\n", $Total_genomes, "\n";
print "Total query species:", "\n", $Total_species_input, "\n";

if ($Total_species_input != $Total_genomes) {
	print $bell;
	print "Total genomes searched ", "(", $Total_genomes, ")",  " is not equal to total query species ", "(", $Total_species_input, ")", "\n";
	print "Duplicated matches (e.g where Canis lupus and Canis lupus familiaris both yeild a match) may have occured, Do you still want to continue to downloading genbank genomes? (Yes/No):";
	my $Yes_No = <STDIN>;
	chomp($Yes_No);
	unless ($Yes_No =~ /^[Yes|yes|Y|y]$/) {
	exit; 
	}
}

if ($Total_species_input == $Total_genomes) {
	print $bell;
	print "Total genomes searched ", "(", $Total_genomes, ")",  " is equal to total query species ", "(", $Total_species_input, ")", "\n";
	print "Everything looks good. Do you want to continue to downloading genbank genomes? (Yes/No):";
	my $Yes_No = <STDIN>;
	chomp($Yes_No);
	if ($Yes_No =~ /^Yes|yes|Y|y$/) {
	print "\n","\n","Proceeding to genbank downloads...","\n\n";
	}else{
	print "exiting pipeline...","\n\n";
	exit;
	}
}





##############################################################################################################################################################################################	

#2. GENBANK GENOMES:
# Needs the genbank assembly summary text file to be stored in working directory (similar to the Refseq assembly file but for Genbank)

unless ( open(SPECIESFILE2, $Refseq_absent_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}


#store the file data as an array
my @target_genbank_species_array = <SPECIESFILE2>;

#close the file
close SPECIESFILE2;

chomp(@target_genbank_species_array); # remove empty lines from array


my $genbank_rep_genomes_found = "";
my $genbank_rep_genomes_absent = "";
my $Filtered_genbank_rep_assembly = "";

foreach my $target2(@target_genbank_species_array){  #Loop over each element, $target2, in @array
    print "\n\n","Looking for ", $target2, "\n";
    open(IN3, "assembly_summary_genbank.txt"); #open the assembly_summary text file, file handle = IN3
	while(<IN3>) { 
	my $line2=$_; #store each line of the text file in $line2
	#unless($line2 =~m/strain/) {
   	unless ($line2 =~m/virus/) {
 	unless ($line2 =~m/isolate/){
   		if ($line2 =~m/genome[\s]+[0-9]+[\s]+[0-9]+[\s]+$target2/){ #if $line2 matches "genome +space + numbers + space +target2
   		$Filtered_genbank_rep_assembly = $Filtered_genbank_rep_assembly.$line2."\n"; #store line in filtered assembly
			if($line2=~m/(ftp[\S]+)/){ #if this line has ftp followed by anything (FTP://...link) take this and store it as link
	    		my $link2=$1;#create variable link and store the FTP link									
	    			if($link2=~m/(GCA_+[0-9]+\.[0-9])/){ #we want to take the GCA accession from the link and store it as accession 
				my $genbank_accession =$1." "; #save the accession which matched the regex above
				$genbank_rep_genomes_found = $genbank_rep_genomes_found.$target2." ".$genbank_accession."\n"; #append the target2 match to genomes found along with the refseq accession number
	    				if($link2=~m/\/(GCA\_[\S]+)/){ #we want to take the \GCA part of the FTP link and repeat it by appending it to the FTP link (see link we want)  
					my $file2 =$1. "_genomic.fna.gz"; #we still need to append  _genomic.fna.gz to get the full genome link (link we want)
					my $final_link2 = $link2."/".$file2; #final step to get link: append GCA_000001405.39_GRCh38.p13_genomic.fna.gz to the FTP link seperated by / 
					system("wget $final_link2"); #wget link to download the genome
									} 
								}
							}
						}
					}
				}
			}if ($genbank_rep_genomes_found !~ m/$target2/){ #if after looping through all lines, there is no match stored in genomes found
			$genbank_rep_genomes_absent = $genbank_rep_genomes_absent.$target2."\n"; #append the miss species to the genomes_not_found variable
		}
	}
	
	
close IN3;

print $bell;

#Output filtered_assembly as a text file, allow user to specify text file name
open my $FILE4, ">", $filtered_genbank_rep_assembly_filename or die("Can't open file. $!");
print $FILE4 $Filtered_genbank_rep_assembly;
close $FILE4;
		
#Output genomes_found as a text file, allow user to specify text file name
open my $FILE5, ">", $genbank_rep_genomes_filename or die("Can't open file. $!");
print $FILE5 $genbank_rep_genomes_found;
close $FILE5;

#Output genomes_not_found as a text file, allow user to specify text file name
open my $FILE6, ">", $Genbank_absent_rep_genomes or die("Can't open file. $!");
print $FILE6 $genbank_rep_genomes_absent;
close $FILE6;

#Store RefSeq Genomes in RefSeq_Genomes Directory 
my $GenBank_Rep_Directory = $Prefix."_GenBank_Rep_Genomes";
system("mkdir $GenBank_Rep_Directory");
system("mv GCA* $GenBank_Rep_Directory");



########################################################################################################################

# Check point for part 2-part 3 progression:

#############################################################################################################################################
## Description:																##
##																		##
## This script counts the number of genomes present on refseq after running the 'search_refseq_genomes.pl script.        			##
## Takes the output refseq_present text file and the output refseq_absent text file from the search_refseq_genomes.pl script as inputs.	##
## Prints total counts for genomes present on reseq, genomes absent on refseq and total genomes.						##
## Total genomes should match the number of query genomes used as input for the 'search_refseq_genomes.pl script.				##
##																		##
#############################################################################################################################################


my $Total_genbank_rep_present = 0;
my $Total_genbank_rep_absent = 0; 
my $Total_genbank_species_input = 0;


####count refseq present:

unless ( open(GENBANK_REP_Present, $genbank_rep_genomes_filename) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @GENBANK_rep_array_present = <GENBANK_REP_Present>;

#close the file
close GENBANK_REP_Present;

chomp(@GENBANK_rep_array_present); # remove empty lines from array


foreach my $species(@GENBANK_rep_array_present){  #Loop over each element, $target, in @array
	$Total_genbank_rep_present = $Total_genbank_rep_present +1 }
	


####count refseq absent:

unless ( open(GENBANK_REP_Absent, $Genbank_absent_rep_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}

#store the file data as an array
my @GENBANK_rep_array_absent = <GENBANK_REP_Absent>;

#close the file
close GENBANK_REP_Absent;

chomp(@GENBANK_rep_array_absent); # remove empty lines from array


foreach my $species(@GENBANK_rep_array_absent){  #Loop over each element, $target, in @array
	$Total_genbank_rep_absent = $Total_genbank_rep_absent +1 }


# Count total number of input species

foreach my $species(@target_genbank_species_array) {
	$Total_genbank_species_input = $Total_genbank_species_input +1 }

my $Total_genbank_genomes = $Total_genbank_rep_present + $Total_genbank_rep_absent;




print "\n","\n", "Checkpoint 1: Counting genomes";
print "Total representative genomes present on genbank:", "\n", $Total_genbank_rep_present, "\n";	
print "Total genomes with no representative genome on genbank:", "\n", $Total_genbank_rep_absent, "\n";
print "Total genomes searched:", "\n", $Total_genbank_genomes, "\n";
print "Total query species:", "\n", $Total_genbank_species_input, "\n";

if ($Total_genbank_species_input != $Total_genbank_genomes) {
	print $bell;
	print "Total genomes searched ", "(", $Total_genbank_genomes, ")",  " is not equal to total query species ", "(", $Total_genbank_species_input, ")", "\n";
	print "Duplicated matches (e.g where Canis lupus and Canis lupus familiaris both yeild a match) may have occured, Do you still want to continue to downloading genbank genomes? (Yes/No):";
	my $Yes_No2 = <STDIN>;
	chomp($Yes_No2);
	unless ($Yes_No2 =~ /^[Yes|yes|Y|y]$/) {
	exit; 
	}
}

if ($Total_genbank_species_input == $Total_genbank_genomes) {
	print $bell;
	print "Total genomes searched ", "(", $Total_genbank_genomes, ")",  " is equal to total query species ", "(", $Total_genbank_species_input, ")", "\n";
	print "Everything looks good. Do you want to continue to downloading genbank non-representative genomes? (Yes/No):";
	my $Yes_No2 = <STDIN>;
	chomp($Yes_No2);
	if ($Yes_No2 =~ /^Yes|yes|Y|y$/) {
	print "\n","\n","Proceeding to genbank non-representative genome downloads...","\n\n";
	}else{
	print "exiting pipeline...","\n\n";
	exit;
	}
}


##############################################################################################################################################################################################		

#!/usr/bin/perl -w

############################################################################################################
## Description:											      ##
## Use this sript to search the assembly_summary_refseq.txt file for specific genomes. If the genome in   ##
## your list gets a hit, it will be listed in an output file. If the genome in your list is not on refseq ##
## it will be listed in a seperate output file. Input species file must be a text file with each query    ##
## species listed on a new line in the text file. This script also retrives the refseq accession number   ##
##for each genome and adds this to the ref_seq present text files.					      ##
##													      ##
## NOTE: Canis lupus will match with both 'Canis lupis' and Canis lupis familiaris'. 		      ##
## Hence three canis lupus matches will be found, where canis lupis familiaris is repeated twice	      ##
## Wasn't sure how to fix this.									      ##
############################################################################################################



unless ( open(SPECIESFILE, $Genbank_absent_rep_genomes) ) {  #open the file. If it doesnt exist, exit and print an error
     print "Filename entered does not exist \n ";
	exit;
}


#store the file data as an array
my @genbank_na_array = <SPECIESFILE>;

#close the file
close SPECIESFILE;

chomp(@genbank_na_array); # remove empty lines from array


my $genbank_na_genomes_found = "";
my $genbank_na_genomes_absent = ""; ##this should be zero if origional species list was obtained from ncbi genomes
my $Filtered_genbank_na_assembly = "";



foreach my $target3(@genbank_na_array){  #Loop over each element, $target, in @array
    print "Looking for ", $target3. "\n";
    open(IN4, "assembly_summary_genbank.txt"); #open the assembly_summary text file, file handle = IN
	while(<IN4>) { 
	my $line3=$_; #store each line of the text file in $line3
	#unless($line3 =~m/strain/) {
   	unless ($line3 =~m/virus/) {
 	unless ($line3 =~m/isolate/){
   		if ($line3 =~m/[na|genome]+[\s]+[0-9]+[\s]+[0-9]+[\s]+$target3/){ #if $line3 matches "genome +space + numbers + space +target
   		$Filtered_genbank_na_assembly = $Filtered_genbank_na_assembly.$line3."\n"; #store line in filtered assembly
			if($line3=~m/(ftp[\S]+)/){ #if this line has ftp followed by anything (FTP://...link) take this and store it as link
	    		my $link3=$1;#create variable link and store the FTP link
	    			if($link3=~m/(GCA_+[0-9]+\.[0-9])/){ #we want to take the GCF accession from the link and store it as accession 
				my $accession3 =$1." "; #save the accession which matched the regex above
				$genbank_na_genomes_found = $genbank_na_genomes_found.$target3." ".$accession3."\n"; #append the target match to genomes found along with the refseq accession number
				if($link3=~m/\/(GCA\_[\S]+)/){ #we want to take the \GCA part of the FTP link and repeat it by appending it to the FTP link (see link we want)  
					my $file3 =$1. "_genomic.fna.gz"; #we still need to append  _genomic.fna.gz to get the full genome link (link we want)
					my $final_link3 = $link3."/".$file3; #final step to get link: append GCA_000001405.39_GRCh38.p13_genomic.fna.gz to the FTP link seperated by / 
					system("wget $final_link3"); #wget link to download the genome
				} 
				}
				}
				}
				}
				}
				#}
			}if ($genbank_na_genomes_found !~ m/$target3/){ #if after looping through all lines, there is no match stored in genomes found
			$genbank_na_genomes_absent = $genbank_na_genomes_absent.$target3."\n"; #append the miss species to the genomes_not_found variable
		}
		}
		



	
close IN4;

print $bell;		
		
#Output filtered_assembly as a text file, allow user to specify text file name
open my $FILE9, ">", $Filtered_genbank_na_assembly_filename or die("Can't open file. $!");
print $FILE9 $Filtered_genbank_na_assembly;
close $FILE9;		
		
		
#Output genomes_found as a text file, allow user to specify text file name
open my $FILE7, ">", $genbank_na_present_filename or die("Can't open file. $!");
print $FILE7 $genbank_na_genomes_found;
close $FILE7;

#Output genomes_not_found as a text file, allow user to specify text file name
open my $FILE8, ">", $genbank_absent_filename or die("Can't open file. $!");
print $FILE8 $genbank_na_genomes_absent;
close $FILE8;

#Store RefSeq Genomes in RefSeq_Genomes Directory 
my $GenBank_NonRep_Directory = $Prefix."_GenBank_non_rep_Genomes";
system("mkdir $GenBank_NonRep_Directory");
system("mv GCA* $GenBank_NonRep_Directory");

###############################################################################################################################################################################


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
my $Absent_from_NCBI_filename = $Prefix."_absent_from_NCBI.txt";
system("cp $genbank_absent_filename $Absent_from_NCBI_filename");
system("mv $Filtered_genbank_na_assembly_filename $genbank_na_present_filename $genbank_absent_filename $GenBank_NonRep_log_sub_Directory");

#Directory for all output files
my $OutDirectory = $Prefix."_Output_files";
system("mkdir $OutDirectory");
system("mv $Prefix* $OutDirectory");

exit;  




##############################################################################################################













