my $PRIMATES = "Primates_Key.txt";
open(IN, $PRIMATES);
@Primates = <IN>;
close IN;

my $fasta_file_extension = "fasta";
my @ALIGNMENTS = (<*$fasta_file_extension>);

my $ISOFORM;
my $GENE_NAME;
my $file;

foreach my $alignment(@ALIGNMENTS){
    my $count = 0;
    my $counter = 0;
    my @already = ();
    #print "Reading in $alignment ... \n";
    open(IN, $alignment);
    {
	local $/; #changes delimiter to nothing. Allows entire file to be read in as one chun
	$Alignment = <IN>; #Stores contents of BLAST file into a scalor
    }
    close IN;
    #print $Alignment;
    my @genes = split('\>', $Alignment);
    foreach my $gene(@genes){
	$counter +=1;
	foreach my $primate(@Primates){
	    ($key, $Species) = split (/\|/, $primate,2);
	    $Species =~ s/\n//g;
	    $key =~ s/\n//g;
	    if ($gene =~ m/.*\_($key).*\n(.*)/i){
		unless($key ~~ @already){
		    push @already, $key;
		    $count +=1;
		}
	    }
	}
    }
    #$count -=1;
    $counter -=1;
    print $alignment." count:\n";
    print $count."\n";
    print $alignment." counter:\n";
    print $counter."\n";
    if ($counter == 62 && $count ==62 ) {
	system("echo $alignment >> Log.txt");
	system("cp $alignment Tree_Alignments");
    }
}
