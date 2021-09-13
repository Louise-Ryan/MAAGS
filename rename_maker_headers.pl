#!/usr/bin/perl

my $fasta_file_extension = $ARGV[0];
chomp $ARGV[0];
my @file_array = (<*$fasta_file_extension>);

#my $outfile;

foreach my $file(@file_array) {
    open(IN, $file);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; 
    }
    close IN;
    my $outfile ="";
    my $newheader="";
    my $head="";
    my $seq="";
    my $gene="";
    my $Head1="";
    my $var = 0;
    my $a = 1;
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
	    $var = $var + $a;
	}
	if ($head =~ m/\>(.*)/i) {
	    $Head1 =">Gene".$var." ".$1;
	    chop($Head1);
	}
	if ($Head1 =~ m/\>.*/i){
	    $newheader = $Head1."\n";
	    $outfile=$outfile.$newheader.$seq;
	}
    }
    open my $NEWFILE, ">", $file or die("Can't open file. $!");
    print $NEWFILE $outfile;
    close $NEWFILE;
}

exit;
