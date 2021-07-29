#!/usr/bin/perl

#Input arguments:

$retained_isoform_file_name = $ARGV[0];#retained_isoform_list from MINE_CDS_annotations.pl output 
$all_isoform_LOG_file = $ARGV[1]; #all_isoform_LOGfile rrom MINE_CDS_annotations.pl outout

#Specify output Directory name
print "Please specify output directory name: ";
$Directory_name = <STDIN>;
chomp $Directory_name;

print "\n Please specify CD-HIT threshold percentage... Eg (70, 80, 90, 100..) :";
$CDHIT_threshold = <STDIN>;
chomp $CDHIT_threshold;

#----------------------------------------------------------------------------------
# 1. Run CD-Hit on all translated_cds.faa files in directory
my $translated_CDS_file_extension = "translated_cds.faa";
my @translated_CDS_array = (<*$translated_CDS_file_extension>);
my $threshold = "0.".$CDHIT_threshold;

foreach my $CDS_file(@translated_CDS_array) {
    print $CDS_file."\n";
    my $CDHIT_output_file_name = $CDS_file."_cdhit_".$CDHIT_threshold;
    my  $CDHIT_cmd ="cd-hit -i $CDS_file -o $CDHIT_output_file_name -c $threshold -d 10000 -g 1 -t 2";
    print $CDHIT_cmd."\n";
    system("$CDHIT_cmd");
}


#-------------------------------------------------------------------------------------
#2. Run Identify_outlier_clusters.pl on all CD_hit output ".clstr" files in directory

my $CLSTR_file_extension = ".clstr";
my @CLSTR_array = (<*$CLSTR_file_extension>);

foreach my $CLSTR_file(@CLSTR_array) {
    if ($CLSTR_file =~ m/(GCF.*\.faa)/i) {
	my $genome_acession = $1;
    print $CLSTR_file."\n";
	my $cmd = "perl Identify_cluster_outliers.pl $CLSTR_file $retained_isoform_file_name $all_isoform_LOG_file $genome_acession";
	print $cmd."\n";
	system("$cmd");
    }
}

my $cluster_outliers_output_directory = $Directory_name."_cluster_outliers_output_files";
system("mkdir $cluster_outliers_output_directory");
system("mv *cluster_outliers_output.txt $cluster_outliers_output_directory");

my $cd_hit_output_directory = $Directory_name."_CDHIT_output_files";
system("mkdir $cd_hit_output_directory");
system("mv *cdhit_$CDHIT_threshold.clstr $cd_hit_output_directory");
system("mv *cdhit_$CDHIT_threshold $cd_hit_output_directory");

    
exit;
