#!/usr/bin/perl

# 1. Align and generate tree for all files in directory
my $file_extension = "fa";
my @filename_array = (<*$file_extension>);


use Cwd qw(cwd);
my $wd = cwd;

foreach my $gene_file(@filename_array){
    my $cmd_align = "java -jar macse_v2.05.jar -prog alignSequences -seq ".$gene_file."\n";
    print $cmd_align;
    system("$cmd_align");
    my $file_prefix = $gene_file;
    $file_prefix =~ s/.fa//;
    my $Alignment_NT_file_oldname = $file_prefix."_NT.fa";
    my $Alignment_AA_file_oldname = $file_prefix."_AA.fa";
    my $Alignment_file_NT = $file_prefix."_NT";
    my $Alignment_file_AA = $file_prefix."_AA";
    system("mv $Alignment_NT_file_oldname $Alignment_file_NT");
    system("mv $Alignment_AA_file_oldname $Alignment_file_AA");
    my $outlines_modified = "";
    my $modified_alignment_file = $file_prefix."_IQ_tree_input_alignment";
    open(IN, $Alignment_file_NT);
    while (<IN>){
	my $LOC = "";
	my $GeneID = "";
	my $line = $_;
	if ($line =~ m/(\s.*\[gbkey\=CDS\])/i) {
	    $rm_description = $1;
	    if ($line =~ m/(gene\=LOC.*?\])/){
	        $LOC = $1;
		$LOC =~ s/\]//;
		$LOC =~ s/gene\=//;
		print $LOC."\n";
	    }elsif ($line !~ m/gene\=/i && $line =~ m/(GeneID.*?\])/i){
		$GeneID = $1;
		$GeneID =~ s/\]//;
	    }
	    $line =~ s/\Q$rm_description\E//;
	    if ($LOC =~ m/[A-Za-z].*/){
		chomp $line;
		$line = $line."_".$LOC."\n";
	    }elsif ($GeneID =~ m/Gene.*/) {
		chomp $line;
		$line = $line."_".$GeneID."\n";
	    }
	} $outlines_modified = $outlines_modified.$line;
    }
    close IN;
    $outlines_modified =~ s/\!/N/g;
    open my $OUTFILE, ">", $modified_alignment_file or die("Can't open file. $!");
    print $OUTFILE $outlines_modified;
    close $OUTFILE; 
    my $tree_file = $file_prefix.".treefile";
    my $cladogram_out = $file_prefix."_Cladogram.jpeg";
    my $phylogram_out = $file_prefix."_Phylogram.jpeg";
    open(IN2, $gene_file);
    my $outgroup = "";
    while(<IN2>){
	my $line = $_;
	if ($line =~ m/(\>.*?Mus_musculus)/i) {
	    $outgroup = $1;
	    $outgroup =~ s/\>//;
	    print $outgroup."\n";
	}
    }
    if ($outgroup =~ m/.*[A-Za-z].*/i) {
	$cmd_iqtree = "./iqtree2 -s ".$modified_alignment_file." -o ".$outgroup." -nt AUTO -bb 1000"."\n";
    }else{
	$cmd_iqtree = "./iqtree2 -s ".$modified_alignment_file."_NT"." -nt AUTO -bb 1000"."\n";
    }
    print $cmd_iqtree;
    system("$cmd_iqtree");
    $cmd_ggtree = "Rscript ggtree_Cladogram.R $wd $tree_file $cladogram_out"."\n";
    print $cmd_ggtree;
    system("$cmd_ggtree");
    my $cmd_ggtree_phylogram = "Rscript ggtree_Phylogram.R $wd $tree_file $phylogram_out"."\n";
    print $cmd_ggtree_phylogram;
    system("$cmd_ggtree_phylogram");
    my $directory_out = $file_prefix."_alignments_and_treefiles_output";
    my $sub_directory = "Additional_IQTREE_output_files";
    my $path_to_sub_directory = $directory_out."/".$sub_directory;
    system("mkdir $directory_out");
    system ("mkdir $path_to_sub_directory");
    system ("mv *log *bionj *gz *mldist $path_to_sub_directory"); 
    system("mv $file_prefix* $directory_out");
}

exit;
