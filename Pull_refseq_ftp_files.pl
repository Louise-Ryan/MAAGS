#!/usr/bin/perl -w

#1. REFSEQ FTP FILE DOWNLOAD
################################################################################################################################
## Search the refseq assembly summary file for target genomes.                                                                ##
## Retrieve FTP link for any sequence file on NCBI FTP page (CDS, mRNA, Protein, Genome ...)                                  ##
## For species with a genome on refseq, list these with their accession number and relevant FTP links in an output text file. ##
## Also list species not available on refseq in a seperate text file.                                                         ##
## Download all available refseq files specified.                                                                             ##
################################################################################################################################

#1.1 import the species target array from text file:

#Species list file is the first argument
$species_file_name = $ARGV[0];

#File Prefix as second argument
$Prefix = $ARGV[1];

#Set Output filenames
my $refseq_genomes_filename = $Prefix."_RefSeq_Genome_Summary.txt";
my $Refseq_absent_genomes = $Prefix."_Species_not_found_on_RefSeq.txt";

#Make an output directory
my $OUT_directory = $Prefix."_output_FTP_Files";
system("mkdir $OUT_directory");

#open the species list file. If it doesnt exist, exit and print an error
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


#1.2. Specify the type of files to be downloaded

#### option 1

#Declare the extension variables
my $CDS_extension = "_cds_from_genomic.fna.gz";
my $Genomic_extension = "_genomic.fna.gz";
my $rna_extension = "_rna.fna.gz";
my $rna_from_genomic_extension = "_rna_from_genomic.fna.gz";
my $translated_CDS_extension = "_translated_cds.faa.gz";
my $protein_extension = "_protein.faa.gz";

#Option list:
print "Choose desired sequence type from the following options. \n";
print "Options: \n";
print "1: "."_cds_from_genomic.fna.gz\n";
print "2: "."_genomic.fna.gz\n";
print "3: "."_rna.fna.gz\n";
print "4: "."_rna_from_genomic.fna.gz\n";
print "5: "."_translated_cds.faa.gz\n";
print "6: "."_protein.faa.gz\n\n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";

#Prompt user to chose option from 1-6
my $Extension_specification_1 = <STDIN>;
chomp $Extension_specification_1;

# Assign user selection to $Extension1 variable
my $Extension_1 = "";

if ($Extension_specification_1 == 1) {
     $Extension_1 = $CDS_extension;
}elsif ($Extension_specification_1 == 2) {
     $Extension_1 = $Genomic_extension;
}elsif ($Extension_specification_1 == 3) {
    $Extension_1 = $rna_extension;
}elsif ($Extension_specification_1 == 4) {
    $Extension_1 = $rna_from_genomic_extension;
}elsif ($Extension_specification_1 == 5) {
    $Extension_1 = $translated_CDS_extension;
}elsif ($Extension_specification_1 == 6) {
    $Extension_1 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}


#Options- Do you want to download more than one file type?

#declaring the YES NO and extension variables 
my $Yes_No ="";
my $Yes_No2 = "";
my $Yes_No3 = "";
my $Yes_No4 = "";
my $Yes_No5 = "";

my $Extension_2 = "";
my $Extension_3 = "";
my $Extension_4 = "";
my $Extension_5 = "";
my $Extension_6 = "";



####option 2 - Do you want to download a second file type?

print "\nDo you want to make another option?(Yes,No)\n";
$Yes_No = <STDIN>;
	chomp($Yes_No);
if ($Yes_No =~ /^[Yes|yes|Y|y]$/) {
print "\nChoose desired sequence type from the following options. \n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";
my $Extension_specification_2 = <STDIN>;
chomp $Extension_specification_2;
if ($Extension_specification_2 == 1) {
     $Extension_2 = $CDS_extension;
}elsif ($Extension_specification_2 == 2) {
     $Extension_2 = $Genomic_extension;
}elsif ($Extension_specification_2 == 3) {
    $Extension_2 = $rna_extension;
}elsif ($Extension_specification_2 == 4) {
    $Extension_2 = $rna_from_genomic_extension;
}elsif ($Extension_specification_2 == 5) {
    $Extension_2 = $translated_CDS_extension;
}elsif ($Extension_specification_2 == 6) {
    $Extension_2 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}
}elsif ($Yes_No =~ /^[No|no|N|n]$/) {
    print "Proceeding to download\n";
}else{
    print "Yes or No not specified...Exiting Pipeline";
    exit;
}




####option 3 - Do you want to download a third file type?
if ($Yes_No =~ /^[Yes|yes|Y|y]$/) {
print "\nDo you want to make another option?(Yes,No)\n";
$Yes_No2 = <STDIN>;
chomp($Yes_No2);
if ($Yes_No2 =~ /^[Yes|yes|Y|y]$/) {
print "\nChoose desired sequence type from the following options. \n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";
my $Extension_specification_3 = <STDIN>;
chomp $Extension_specification_3;
if ($Extension_specification_3 == 1) {
     $Extension_3 = $CDS_extension;
}elsif ($Extension_specification_3 == 2) {
     $Extension_3 = $Genomic_extension;
}elsif ($Extension_specification_3 == 3) {
    $Extension_3 = $rna_extension;
}elsif ($Extension_specification_3 == 4) {
    $Extension_3 = $rna_from_genomic_extension;
}elsif ($Extension_specification_3 == 5) {
    $Extension_3 = $translated_CDS_extension;
}elsif ($Extension_specification_3 == 6) {
    $Extension_3 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}
}elsif ($Yes_No2 =~ /^[No|no|N|n]$/) {
    print "Proceeding to download your selection..."."\n";
}else{
    print "Yes or No not specified.....Exiting Pipeline";
    exit;
}
}



####option 4 - Do you want to download a fourth file type?
if ($Yes_No2 =~ /^[Yes|yes|Y|y]$/) {
print "\nDo you want to make another option?(Yes,No)\n";
$Yes_No3 = <STDIN>;
chomp($Yes_No3);
if ($Yes_No3 =~ /^[Yes|yes|Y|y]$/) {
print "\nChoose desired sequence type from the following options. \n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";
my $Extension_specification_4 = <STDIN>;
chomp $Extension_specification_4;
if ($Extension_specification_4 == 1) {
     $Extension_4 = $CDS_extension;
}elsif ($Extension_specification_4 == 2) {
     $Extension_4 = $Genomic_extension;
}elsif ($Extension_specification_4 == 3) {
    $Extension_4 = $rna_extension;
}elsif ($Extension_specification_4 == 4) {
    $Extension_4 = $rna_from_genomic_extension;
}elsif ($Extension_specification_4 == 5) {
    $Extension_4 = $translated_CDS_extension;
}elsif ($Extension_specification_4 == 6) {
    $Extension_4 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}
}elsif ($Yes_No3 =~ /^[No|no|N|n]$/) {
    print "Proceeding to download your selection..."."\n";
}else{
    print "Yes or No not specified.....Exiting Pipeline";
    exit;
}
}



####option 5 - Do you want to download a fifth file type?
if ($Yes_No3 =~ /^[Yes|yes|Y|y]$/) { 
print "\nDo you want to make another option?(Yes,No)\n";
 $Yes_No4 = <STDIN>;
	chomp($Yes_No4);
if ($Yes_No4 =~ /^[Yes|yes|Y|y]$/) {
print "\nChoose desired sequence type from the following options. \n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";
my $Extension_specification_5 = <STDIN>;
chomp $Extension_specification_5;
if ($Extension_specification_5 == 1) {
     $Extension_5 = $CDS_extension;
}elsif ($Extension_specification_5 == 2) {
     $Extension_5 = $Genomic_extension;
}elsif ($Extension_specification_5 == 3) {
    $Extension_5 = $rna_extension;
}elsif ($Extension_specification_5 == 4) {
    $Extension_5 = $rna_from_genomic_extension;
}elsif ($Extension_specification_5 == 5) {
    $Extension_5 = $translated_CDS_extension;
}elsif ($Extension_specification_5 == 6) {
    $Extension_5 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}
}elsif ($Yes_No4 =~ /^[No|no|N|n]$/) {
    print "Proceeding to download your selection..."."\n";
}else{
    print "Yes or No not specified.....Exiting Pipeline";
    exit;
}
}

####Option 6 - do you want to download a sixth file type? (last option-- but can edit the script to include other extensions if needed)
if ($Yes_No4 =~ /^[Yes|yes|Y|y]$/) { 
print "\nDo you want to make one last option?(Yes,No)\n";
$Yes_No5 = <STDIN>;
	chomp($Yes_No5);
if ($Yes_No5 =~ /^[Yes|yes|Y|y]$/) {
print "\nChoose desired sequence type from the following options. \n";
print "Please specify the option number (1 to 6) of the extension for the file type you wan't to retrieve \n";
my $Extension_specification_6 = <STDIN>;
chomp $Extension_specification_6;
if ($Extension_specification_6 == 1) {
     $Extension_6 = $CDS_extension;
}elsif ($Extension_specification_6 == 2) {
     $Extension_6 = $Genomic_extension;
}elsif ($Extension_specification_6 == 3) {
    $Extension_6 = $rna_extension;
}elsif ($Extension_specification_6 == 4) {
    $Extension_6 = $rna_from_genomic_extension;
}elsif ($Extension_specification_6 == 5) {
    $Extension_6 = $translated_CDS_extension;
}elsif ($Extension_specification_6 == 6) {
    $Extension_6 = $protein_extension;
}else{
    print "Number between 1-6 not specified. Exiting pipeline";
    exit;
}
}elsif ($Yes_No5 =~ /^[No|no|N|n]$/) {
    print "Proceeding to download your selection..."."\n";
}else{
    print "Yes or No not specified.....Exiting Pipeline";
    exit;
}
}


#### Loop through the Ref_seq assembly summary file to retrieve the user_specified FTP links for user specified each target species

my $Genomes_found = "";
my $Genomes_not_found = "";


foreach my $target(@target_species_array){  #Loop over each element, $target, in @array
    print "\n\n","Looking for ", $target, "\n";
    open(IN2, "assembly_summary_refseq.txt"); #open the assembly_summary text file, file handle = IN
    while(<IN2>) {
	my $line=$_; #store each line of the text file in $line
	if ($line =~m/genome[\s]+[0-9]+[\s]+[0-9]+[\s]+$target+[\t]/){ #if $line matches "genome +space + numbers + space +target
	    if($line=~m/(ftp[\S]+)/){ #if this line has ftp followed by anything (FTP://...link) take this and store it as link
		my $link=$1;#create variable link and store the FTP link
		if($link=~m/(GCF_+[0-9]+\.[0-9])/){ #we want to take the GCF accession from the link and store it as accession
		    my $accession =$1." "; #save the accession which matched the regex above
		    #$Genomes_found = $Genomes_found.$target." ".$accession."\n"; #append the target match to genomes found along with the refseq accession number
		    if($link=~m/\/(GCF\_[\S]+)/){ #we want to take the \GCF part of the FTP link and repeat it by appending it to the FTP liK
			$Genomes_found = $Genomes_found.$target."\t".$accession."\n";
			my $file =$1.$Extension_1 ; #we still need to append  _genomic.fna.gz to get the full genome link (link we want)
			my $file2 =$1.$Extension_2 ;
		        my $file3 =$1.$Extension_3 ;
			my $file4 =$1.$Extension_4 ;
			my $file5 =$1.$Extension_5 ;
			my $file6 =$1.$Extension_6 ;
			my $final_link = $link."/".$file;
			my $final_link2 = $link."/".$file2;
			my $final_link3 = $link."/".$file3;
			my $final_link4 = $link."/".$file4;
			my $final_link5 = $link."/".$file5;
			my $final_link6 = $link."/".$file6;
			if($final_link =~ m/(\.gz)$/) {
			    system("wget $final_link");
			    if($final_link2 =~ m/(\.gz)$/) {
				system("wget $final_link2");
				if($final_link3 =~ m/(\.gz)$/) {
				    system("wget $final_link3");
				    if($final_link4 =~ m/(\.gz)$/) {
					system("wget $final_link4");
					if($final_link5 =~ m/(\.gz)$/) {
					    system("wget $final_link5");
					    if($final_link6 =~ m/(\.gz)$/) {
						system("wget $final_link6");
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }if ($Genomes_found !~ m/$target+[\t]/){ #if after looping through all lines, there is no match stored in genomes found
	$Genomes_not_found = $Genomes_not_found.$target."\n"; #append the miss species to the genomes_not_found variable
    }
}
	
	
close IN2;

#my $bell = chr(7);
#print $bell;
		
#Output genomes_found as a text file
open my $FILE2, ">", $refseq_genomes_filename or die("Can't open file. $!");
print $FILE2 $Genomes_found;
close $FILE2;

#Output genomes_not_found as a text file
open my $FILE3, ">", $Refseq_absent_genomes or die("Can't open file. $!");
print $FILE3 $Genomes_not_found;
close $FILE3;


#Organise into directories

#CDS_from_genomic files:
my @array1 = (<*$CDS_extension>);
unless (@array1 == 0) {
    my $dir1 = $OUT_directory."/".$Prefix."_CDS_from_genomic_files";
    system("mkdir $dir1");
    system("mv *$CDS_extension $dir1");
}

#rna from genomic extension
my @array2 = (<*$rna_from_genomic_extension>);
unless (@array2 == 0) {
    my $dir2 = $OUT_directory."/".$Prefix."_rna_from_genomic_files";
    system("mkdir $dir2");
    system("mv *$rna_from_genomic_extension $dir2");
}


#RNA fna extension
my @array3 = (<*$rna_extension>);
unless (@array3 == 0) {
    my $dir3 = $OUT_directory."/".$Prefix."_RNA_fna_files";
    system("mkdir $dir3");
    system("mv *$rna_extension $dir3");
}

#genomic files:
my @array4 = (<*$Genomic_extension>);
unless (@array4 == 0) {
    my $dir4 = $OUT_directory."/".$Prefix."_Genomic_fna_files";
    system("mkdir $dir4");
    system("mv *$Genomic_extension $dir4");
}

#translated cds extension
my @array5 = (<*$translated_CDS_extension>);
unless (@array5 == 0) {
    my $dir5 = $OUT_directory."/".$Prefix."_translated_cds_files";
    system("mkdir $dir5");
    system("mv *$translated_CDS_extension $dir5");
}

#protein extension
my @array6 = (<*$protein_extension>);
unless (@array6 == 0) {
    my $dir6 = $OUT_directory."/".$Prefix."_protein_files";
    system("mkdir $dir6");
    system("mv *$protein_extension $dir6");
}

#Move log files to out directory
system("mv $refseq_genomes_filename  $OUT_directory");
system("mv $Refseq_absent_genomes $OUT_directory");

#completion message
print "\n\nFile download complete.\n\n";

exit;





