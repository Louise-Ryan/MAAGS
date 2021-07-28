my $Cluster_file =$ARGV[0];
chomp $Cluster_file; #This is the .clustl file from CD-hit output

my $Retained_isoform_list =$ARGV[1];
chomp $Retained_isoform_list; #This is the retained_isoform_list from MINE_CDS_annotations.pl output

my $ALL_ISOFORM_log = $ARGV[2];
chomp $ALL_ISOFORM_log; #This is the all_isoform_LOGFILE from MINE_CDS_annotations.pl output

my $genome = $ARGV[3];
chomp $genome; #This is the genome of interest

if ($genome =~ m/(GCF+[\S\s]+_translated)/){
        $genome_id = $1;
	$genome_id =~ s/_translated//;
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------
#Filter retained isoforms for genome of interest to speed up script


open (IN, $Retained_isoform_list);

my @long_retained_isoform_array = (<IN>);
close IN;

my $output_isoform_list = "";

foreach my $iso(@long_retained_isoform_array){
    if ($iso =~ m/$genome_id/i){
	$output_isoform_list = $output_isoform_list.$iso;
    }
}

my $Filtered_Retained_isoform_list = "Filtered_".$genome_id."_retained_isoforms_LOGFILE.txt";

open my $FILE, ">", $Filtered_Retained_isoform_list or die("Can't open file. $!");
print $FILE $output_isoform_list;
close $FILE;



#-------------------------------------------------------------------------------------------------------------------------------------------------------------

my $print_out_list = "";

$print_out_list =   $print_out_list."\n\nOutput of 'Identify_cluster_outliers.pl' for: \n"."Genome file: ".$genome_id."\nCD-hit Cluster file: ".$Cluster_file.": \n\n";

$print_out_list = $print_out_list."Clusters of interest - containing 'retained isoform' from MINE_CDS_annotations.pl: \n\n";

#-------------------------------------------------------------------------------------------------------------------------------------------------------------


unless ( open(IN2,$Filtered_Retained_isoform_list) ) {
    print "Filename entered does not exist \n ";
	exit;
}


my @retained_isoform_array = <IN2>;
close IN2;

my $potential_GOI = "";

foreach my $element(@retained_isoform_array){
      if ($element =~ m/(XP_.*?\s)/i || $element =~ m/(NP_.*?\s)/i) {
	   my  $retained_isoform = $1;
	   $retained_isoform =~ s/\s//;
	   {local $/ = ">Cluster"; #  change line delimter
	    open(IN1, $Cluster_file);
	    while(<IN1>) {
		chomp;
		my $cluster_line = $_;
		if ($cluster_line =~ m/.*$retained_isoform.*/i) {
		    my $cluster = ">Cluster".$cluster_line;
		    $print_out_list = $print_out_list.$cluster."\n";
	   {local $/ = "\n";
	   my @cluster_elements = split("\n", $cluster);
	   foreach my $clust(@cluster_elements){
	       if ($clust =~  m/(XP_.*\.\.\.)/i || $clust =~ m/(NP_.*\.\.\.)/i) {
	       my $cluster_element = $1;
	       $cluster_element  =~ s/\.\.\.//;
	   {local $/ = "Transcript lengths for";
		 open(IN3, $ALL_ISOFORM_log);
		 while (<IN3>) {
		     chomp;
		     my $isoform_cluster = $_;
		     if ($isoform_cluster =~  m/.*$retained_isoform.*/i){
		     if ($isoform_cluster !~ m/$cluster_element/i) {
			 $potential_GOI = $potential_GOI.$cluster_element."\n";
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
      }
}

close IN1;
close IN3;



my $GOI_list = "";
my $match_test = "";
my @potential_GOI_array = split("\n", $potential_GOI);
my $final_GOI_output_list = "";
my $matches = "";

foreach $GOI(@potential_GOI_array){
    {local $/ = ">lcl";
     open(IN4, $genome);
     while (<IN4>) {
     chomp;
     $seq = $_;
     if ($seq =~ m/$GOI/i) {
	 if ($seq =~ m/(\[protein\=.*?\])/i) {
	     my $protein_name = $1;
	     if ($seq =~ m/(\[gene\=.*?\])/i || $seq =~ m/(GENEID:.*?\])/i){
		 my $gene_name = $1;
	         $GOI_list = $GOI_list.$GOI."|".$gene_name."|".$protein_name."\n";
		 $match_test = $match_test.">".$genome_id."_".$gene_name.": ".$GOI."\n";
	 }
     }
     }
    }
}
}


	   

my @GOI_array = split("\n", $GOI_list);

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

my @GOI_remove_duplicates = uniq(@GOI_array);

foreach $G(@GOI_remove_duplicates){
    $final_GOI_output_list = $final_GOI_output_list.$G."\n";
    
}




$print_out_list =  $print_out_list."\n\nGenes belonging to clusters, where the gene is not an isoform of the genes in that cluster: \n\n";
$print_out_list = $print_out_list.$final_GOI_output_list."\n\n";


my @match_array = split("\n", $match_test);

my @match_test_remove_duplicates = uniq(@match_array);

foreach my $M(@match_test_remove_duplicates){
    if ($M =~ m/(>.*\[gene=.*?\]:)/){
	my $LOCUS_match = $1;
    open(IN2, $Filtered_Retained_isoform_list);
    while(<IN2>) {
	my $potential_match = $_;
	if ($potential_match =~ m/\Q$LOCUS_match\E.*/i) {
	    $matches = $matches.$M."\n";
	}
    }
    }
}

$print_out_list = $print_out_list."Of the above genes, these genes have already been included in the Final Seq file output of MINE_CDS_annotations: \n";
$print_out_list =  $print_out_list.$matches."\n\n";


foreach my $M2(@match_test_remove_duplicates){
    	if ($matches !~ m/\Q$M2\E/si) {
	$true_GOI = $true_GOI.$M2."\n";
	}
}


$print_out_list =  $print_out_list."Of the above genes, the following have not been included in the Final Seq file output of MINE_CDS_annotations.pl and may be of interest: \n\n";


if ($true_GOI =~ m/>.*/){
    $print_out_list = $print_out_list.$true_GOI."\n";
}else{
    $print_out_list = $print_out_list."No hits! It looks like MINE_CDS_annotations picked up all potenital duplicates above specified CD-hit percentage identity threshold!\n\n";
}


#print $print_out_list;

if ($Cluster_file =~ m/\.clstr/i){
    my $new_cluster_name = $1;
    $new_cluster_name =~ s/\.clstr//;
}

my $output_file_name = $genome_id."_".$new_Cluster_name."cluster_outliers_output.txt";

open my $FILE, ">", $output_file_name or die("Can't open file. $!");
print $FILE $print_out_list;
close $FILE;  
    
exit;
