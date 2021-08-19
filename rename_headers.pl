#!/usr/bin/perl

my $fasta_file_extension = "fa";
my @file_array = (<*$fasta_file_extension>);

my $outfile;

foreach my $file(@file_array) {
    my $outfile = "";
    open(IN, $file);
    my @GENES = <IN>;
    close IN;
    $GENES = join('', @GENES);
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    $head=">".$1."\n";
	    $seq=$2;
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
	print $newheader;
	$outfile=$outfile.$newheader.$seq;
    }
    print $outfile;
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

exit;


