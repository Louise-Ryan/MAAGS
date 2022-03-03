my @files=(<*NT>);

foreach my $f(@files){
    if ($f =~ m/(.*?_).*/i) {
	my $gene = $1;
	$gene =~ s/\_//;
	$tree = $gene."_trimmed_tree.tre";
	system("mv trimmed_tree.tre $tree");
    }
}
