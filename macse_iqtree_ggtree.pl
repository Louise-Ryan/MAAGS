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
    system("sed -ie s/\!/N/g $Alignment_file_NT");
    my $tree_file = $Alignment_file_NT.".treefile";
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
	$cmd_iqtree = "./iqtree2 -s ".$Alignment_file_NT." -o ".$outgroup." -nt AUTO -bb 1000"."\n";
    }else{
	$cmd_iqtree = "./iqtree2 -s ".$Alignment_file_NT." -nt AUTO -bb 1000"."\n";
    }
    print $cmd_iqtree;
    system("$cmd_iqtree");
    $cmd_ggtree = "ggtree_Cladogram.R $wd $tree_file $cladogram_out"."\n";
    print $cmd_ggtree;
    system("$cmd_ggtree");
    my $cmd_ggtree_phylogram = "ggtree_Phylogram.R $wd $tree_file $phylogram_out"."\n";
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
