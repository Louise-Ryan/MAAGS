my $RFILE = "May_all.fa";
my @receptor_files = (<*$RFILE>);
#my $receptor_file = shift(@receptor_files);
my $receptor_csv = "Receptor_Counts.csv";
my $INFO = "Genome, Total, Functional, Pseudogenes, VR Total, VR Functional, VR Pseudogenes, OR Total, OR Functional, OR Pseudogene, TasR Total, TasR functional, TasR pseudogene, TAAR Total, TAAR functional, TAAr pseudogene\n";
foreach my $files(@receptor_files){
    my $TOTAL = 0;
    my $TOTAL_functional = 0;
    my $TOTAL_pseudo = 0;
    my $VR_count = 0;
    my $VR_pseudo = 0;
    my $VR_functional = 0;
    my $TAS_count = 0;
    my $TAS_pseudo = 0;
    my $TAS_functional = 0;
    my $OR_total = 0;
    my $OR_pseudo = 0;
    my $OR_functional = 0;
    my $TAAR_total = 0;
    my $TAAR_pseudo = 0;
    my $TAAR_functional = 0;
    my $genome;
    if ($files =~ m/([\S]+)\_$RFILE/){
	$genome = $1; 
    }
    open(IN, $files);
    while(<IN>){
	my $line = $_;
	if ($line =~ m/\>.*/){
	    $TOTAL +=1;
	}
	if ($line =~ m/pseudo/i){
	    $TOTAL_pseudo +=1;
	}
	if ($line =~ m/VN/ || $line =~ m/Vom/ || $line =~ m/Vmn/ || $line =~ m/V1R/){
	    $VR_count +=1;
	    if ($line =~ m/pseudo/i){
		$VR_pseudo +=1;
	    }
	}
	if ($line =~ m/TAS/ || $line =~ m/T2R/){
	    $TAS_count +=1;
	    if ($line =~m/pseudo/i){
		$TAS_pseudo +=1;
	    }
	}
	if ($line =~ m/OR/ || $line =~ m/Olr/i || $line =~ m/Olfr/i){
	    $OR_total +=1;
	    if ($line =~m/pseudo/i){
		$OR_pseudo +=1;
	    }
	}
	if ($line =~ m/TAAR/i){
	    $TAAR_total +=1;
	    if ($line =~m/pseudo/i){
		$TAAR_pseudo +=1;
	    }
	}
    }
    $TOTAL_functional = $TOTAL - $TOTAL_pseudo;
    $VR_functional = $VR_count - $VR_pseudo;
    $TAS_functional = $TAS_count - $TAS_pseudo;
    $OR_functional = $OR_total - $OR_pseudo;
    $TAAR_functional = $TAAR_total - $TAAR_pseudo;
    #$INFO = $INFO.$TOTAL.", ".$TOTAL_functional.", ".$TOTAL_pseudo.", ".$VR_count.", ".$VR_functional.", ".$VR_pseudo.", ".$TAS_count.", ".$TAS_functional.", ".$TAS_pseudo.", ".$OR_total.", ".$OR_functional.", ".$OR_pseudo.", ".$TAAR_total.", ".$TAAR_functional.", ".$TAAR_pseudo."\n";
    $INFO = $INFO.$genome.",".$TOTAL.", ".$TOTAL_functional.", ".$TOTAL_pseudo.", ".$VR_count.", ".$VR_functional.", ".$VR_pseudo.", ".$TAS_count.", ".$TAS_functional.", ".$TAS_pseudo.", ".$OR_total.", ".$OR_functional.", ".$OR_pseudo.", ".$TAAR_total.", ".$TAAR_functional.", ".$TAAR_pseudo."\n";
}

print $INFO;
#open(OUT, $receptor_csv);
#print OUT $INFO;
#close OUT;
