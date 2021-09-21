#!/usr/bin/perl

my $fasta_file_extension = "fa";
my @file_array = (<*$fasta_file_extension>);

#my $outfile;

foreach my $file(@file_array) {
    open(IN, $file);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; #Stores contents of BLAST file into a scalor
    }
    close IN;
    my $outfile ="";
    my $newheader="";
    my $head="";
    my $seq="";
    my $gene="";
    my $Head1="";
    my $LOC = "";
    my $Genome ="";
    my $prot_desc = "";
    my $Gene_ID ="";
    if($GENES =~ m/.*?(\.\.\>).*/i) {
	$rm = $1;
	print $rm."\n\n";
	$GENES =~ s/\Q$rm\E//g;
    }
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	   $head=">".$1."\n";
	   $seq=$2;
	}
	my $Head1 = "";
	if ($head =~ m/(\>.*?\s)/i) {
	    $Head1 = $1;
	    chop($Head1);
#	    print $Head1."\n";
	}
	my $Genome= "";
	if ($head =~ m/(GC.*?\_.*?\_)/i){
	    $Genome = $1;
	    chop($Genome);
#	    print $Genome."\n";
	}
	my $LOC = "";
	if ($head =~ m/(LOC.*?\])/) {
	    $LOC = "_".$1;
	    chop ($LOC);
#	    print $LOC."\n";
	}
	my $Gene_ID = "";
	if ($head =~ m/.*Macaca_fascicularis.*/i) { #Macaca Fas has no LOC IDs
	    if ($head =~ m/(GENEID:.*?\])/i) {
		$Gene_ID = "_".$1;
		chop($Gene_ID);
	    }
	}
	if ($head !~ m/.*Macaca_fascicularis.*/i) {
	    $Gene_ID = "";
	}
	my $prot_desc = "";
	if ($head =~ m/protein\=(.*?\])/i) {
	    $prot_desc = $1;
	    chop ($prot_desc);
#	    print $prot_desc."\n";
	}
	if ($Head1 =~ m/\>.*/i){
	    $newheader = $Head1.$LOC.$Gene_ID." ".$Genome." ".$prot_desc."\n";
#	    print $newheader;
	    $outfile=$outfile.$newheader.$seq;
	}
    }
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

exit;


