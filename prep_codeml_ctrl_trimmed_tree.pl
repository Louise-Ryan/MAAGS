#!/usr/bin/perl

my @alignments=(<*NT>);
my $alt_ctlfile="alt_codeml_.ctl";
my $null_ctlfile="null_codeml_.ctl";
my $tree_file = "trimmed_tree.tre";

my $outfile;

foreach $aln(@alignments){
    #system("rename_headers_species_only.pl $aln");
    system("java -jar macse_v2.05.jar -prog exportAlignment -align $aln -codonForFinalStop --- -codonForInternalStop NNN");
    my $newaln = $aln."_NT";
    system("mv $newaln $aln");
    system("fasta2phy.pl $aln");
    my $gene = "";
    if ($aln =~ m/(.*?\_).*/i) {
        $gene = $1;
	$gene =~ s/\_//i;
	print $gene."\n";
    }
    my $outfile = "";
    open(IN, $alt_ctlfile);
    while(<IN>){
	my $line = $_;
	if ($line =~ m/(seqfile.*)(\*.*)/i){
	    my $modline = $1;
	    my $starline = $2;
	    $modline = $modline.$aln.".phy ".$starline."\n";
	    $outfile = $outfile.$modline;
	}
	elsif ($line =~ m/(outfile.*)(\*.*)/i) {
	    my $modline = $1;
            my $starline = $2;
	    my $out = $aln;
            $out =~ s/_NT//i;
            $out = $out.".M8.out";
            $modline = $modline.$out." ".$starline."\n";
            $outfile = $outfile.$modline;
	}
	elsif ($line =~ m/(treefile.*)(\*.*)/i){
	    my $modline = $1;
	    my $starline = $2;
	    $modline = $modline.$tree_file." ".$starline."\n";
	    $outfile = $outfile.$modline;
	}
	else {
	    $outfile = $outfile.$line;
	}
	my $alt_out_ctl = $alt_ctlfile;
	$alt_out_ctl =~ s/\.ctl//i;
	$alt_out_ctl = $alt_out_ctl.$gene.".ctl";
	open my $FILE, ">", $alt_out_ctl or die("Can't open file. $!");
	print $FILE $outfile;
	close $FILE;
	#system("codeml $alt_out_ctl");
    }
    my $outfile ="";
    open(IN2, $null_ctlfile);
    while(<IN2>) {
	my $line = $_;
        if ($line =~ m/(seqfile.*)(\*.*)/i){
            my $modline = $1;
            my $starline = $2;
            $modline = $modline.$aln." ".$starline."\n";
            $outfile = $outfile.$modline;
        }
        elsif ($line =~ m/(outfile.*)(\*.*)/i) {
            my $modline = $1;
            my $starline = $2;
            my $out = $aln;
            $out =~ s/_NT//i;
            $out = $out.".M7.out";
            $modline = $modline.$out." ".$starline."\n";
            $outfile = $outfile.$modline;
        }
        elsif ($line =~ m/(treefile.*)(\*.*)/i){
            my $modline = $1;
            my $starline = $2;
            $modline = $modline.$tree_file." ".$starline."\n";
            $outfile = $outfile.$modline;
        }
        else {
            $outfile = $outfile.$line;
        }
	my $null_out_ctl = $null_ctlfile;
        $null_out_ctl =~ s/\.ctl//i;
        $null_out_ctl = $null_out_ctl.$gene.".ctl";
        open my $FILE2, ">", $null_out_ctl or die("Can't open file. $!");
        print $FILE2 $outfile;
        close $FILE2;
	#system("codeml $null_out_ctl");
    } # Run CodeML
    #system("codeml $alt_out_ctl");
    #system("codeml $null_out_ctl");
}
