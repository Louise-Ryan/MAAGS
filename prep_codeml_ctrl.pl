#!/usr/bin/perl

#my @alignments=(<*NT>); If you want to iterate this over many in one dir, uncomment this and comment next line
#my $alt_ctlfile="alt_codeml_.ctl";
#my $null_ctlfile="null_codeml_.ctl";
#my $tree_file = (<*tre>);

#Uncomment above if running in directory for more simple script

#Below is for running remote
use Cwd qw(cwd);
my $wd = cwd;
my $gene= $ARGV[0]; #This will let me to include a file path to the file
my $aln_path = $wd."/".$gene."/\*NT";
my @alignments = (<$aln_path>);
my $outfile;

foreach $aln(@alignments){
    system("rename_headers_species_only.pl $aln");
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
    }
}
