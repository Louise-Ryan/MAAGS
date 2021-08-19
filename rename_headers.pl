#!/usr/bin/perl

my $fasta_file_extension = "fa";
my @file_array = (<*$fasta_file_extension>);

my $outfile;

foreach my $file(@file_array) {
    my $outfile ="";
    my $newheader="";
    open(IN, $file);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; #Stores contents of BLAST file into a scalor
    }
    close IN;
    if($GENES =~ m/.*?(\.\.\>).*/i) {
	$rm = $1;
	print $rm."\n\n";
	$GENES =~ s/\Q$rm\E//g;
    }
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    my $head=">".$1."\n";
	    my $seq=$2;
	}
	if ($head =~ m/(\>.*?\s)/i) {
	    $Head1 = $1;
	    chop($Head1);
#	    print $Head1."\n";
	}
	if ($head =~ m/(GC.*?\_.*?\_)/i){
	    $Genome = $1;
	    chop($Genome);
#	    print $Genome."\n";
	}
	if ($head =~ m/(LOC.*?\])/) {
	    $LOC = "_".$1;
	    chop ($LOC);
#	    print $LOC."\n";
	}
	if ($head =~ m/protein\=(.*?\])/i) {
	    $prot_desc = $1;
	    chop ($prot_desc);
#	    print $prot_desc."\n";
	}
	my $newheader = $Head1.$LOC." ".$Genome." ".$prot_desc."\n";
#	print $newheader;
	$outfile=$outfile.$newheader.$seq;
    }
#    print $outfile;
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

exit;


