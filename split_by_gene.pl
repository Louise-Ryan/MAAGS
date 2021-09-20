#!/usr/bin/perl

my $file_extension = ARGV[0];
my @FILES = <*$file_extension>;

foreach my $file (@files) {
    open (IN, $file);
     {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$GENES = <IN>; 
    }
    close IN;
    @GENES=[];
    @GENES=split(/\>/,$GENES);
    foreach $gene(@GENES) {
	if($gene=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    $head=">".$1."\n";
	    $seq=$2;
	}
	if ($head =~ m/\>(.*)?_/i) {
	    my $GENE_NAME = $1;
	    my $GENEFILE = $GENE_NAME."_Gene_Seq_File.fa";
	    my $GENE_STORE = $head.$seq;
	    open my $FILE, ">", $GENEFILE or die("Can't open file. $!");
	    print $FILE $GENE_STORE;
	    close $FILE;
	}
    }
}
	    
    
	
