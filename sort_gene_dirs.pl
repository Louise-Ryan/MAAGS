my @files=(<*NT>);

foreach my $f(@files){
    if ($f =~ m/(.*?_).*/i) {
	my $gene = $1;
	$gene =~ s/\_//;
	system ("mkdir $gene");
	system( "mv $f $gene");
	system ("cp *ctl *tre *pl *sh *jar $gene");
    }
}
