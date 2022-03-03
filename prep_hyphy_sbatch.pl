my @files=(<*NT>);

my $sbatch_file = "sbatch_hyphy.sh";
foreach my $f(@files){
    if ($f =~ m/(.*?_).*/i) {
	my $gene = $1;
	$gene =~ s/\_//;
	my $tree = $gene."_trimmed_tree.tre";
	my $output_abs = $gene."_absrel.txt";
	my $output_meme = $gene."_MEME.txt";
	my $cmd_abs = "hyphy absrel --alignment $f --tree $tree \>\> $output_abs";
	my $cmd_meme = "hyphy meme --alignment $f --tree $tree \>\> $output_meme";
	system ("echo \Q$cmd_abs\E >> sbatch_hyphy.sh");
	system("echo \Q$cmd_meme\E >> sbatch_hyphy.sh");
    }
}


#hyphy absrel --alignment MEIS2_ENST00000561208_TOGA_Primates_longest_NT --tree MEIS2_trimmed_tree.tre >> MEIS2_absrel.txt
#hyphy meme --alignment MEIS2_ENST00000561208_TOGA_Primates_longest_NT --tree MEIS2_trimmed_tree.tre >> MEIS2_MEME.txt
