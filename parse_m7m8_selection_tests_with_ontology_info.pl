#!/usr/bin/perl

open(IN, "GOs.txt"); #GOs is a text file with Gene, Ontology\n format.
my @GENES = <IN>;
close IN;

my $csv_table = $csv_table."Gene, kappaM7, kappaM8, npM7, npM8, df, lnLM7, lnLM8, chivalue, pvalue, position, aminoacid, pr(w>1), dNdS, Ontology\n";
foreach my $line(@GENES){
    my ($gene, $ontology) = split ("\,", $line, 2);
    my $kappam7;
    my $kappam8;
    my $npm7;
    my $npm8;
    my $lnLm7;
    my $lnlm7;
    my $df;
    $gene =~ s/\n//g;
    $gene =~ s/\s//g;
    print $gene."\n";
    my @GENE_ARRAY = (<$gene*>);
    foreach my $element(@GENE_ARRAY){
	if ($element =~ m/.*M7\.out/i){
	    print "Opening $element ...!\n";
	    open(M7, $element);
	    while(<M7>) {
		my $line = $_;
		if ($line =~ m/.*kappa.*\=.*([0-9]+\.[0-9]+).*/){
		    $kappam7 = $1;
		    print "kappa: $kappam7\n";
		}
		if ($line =~ m/.*lnL\(.*?np\:\s([0-9]+).*\s(\-[0-9]+\.[0-9]+).*/i){
		    $npm7 = $1;
		    print "np: $npm7\n";
		    $lnLm7 = $2;
		    print "lNL: $lnLm7\n";
		}
	    }
	}
	if ($element =~ m/.*M8\.out/i){
	    print "Opening $element ...!\n";
	    open(M8, $element);
	    while(<M8>) {
		my $line = $_;
		if ($line =~ m/.*kappa.*\=.*([0-9]+\.[0-9]+).*/){
		    $kappam8 = $1;
		    print "kappa: $kappam8\n";
		}
		if ($line =~ m/.*lnL\(.*?np\:\s([0-9]+).*\s(\-[0-9]+\.[0-9]+).*/i){
		    $npm8 = $1;
		    print "np: $npm8\n";
		    $lnLm8 = $2;
		    print "lNL: $lnLm8\n";
		}		
	    }
	    my $df = $npm8 - $npm7; #Degrees of freedom
	    print "df: $df\n";
	    my $chivalue = 2*($lnLm8 - $lnLm7); #ChiValues
	    print "Chi: ".$chivalue."\n";
	    system("Rscript get_chisquare_pvalue.R $chivalue"); #get p-value with R script
	    open(tmp, "tmp_chivalue.txt");
	    my $pvalue = <tmp>;
	    close tmp;
	    system("rm tmp_chivalue.txt");
	    $pvalue =~ s/\s//g;
	    $pvalue =~ s/\n//g;
	    print "pvalue: $pvalue\n";
	    my $stats = $gene.", ".$kappam7.", ".$kappam8.", ".$npm7.", ".$npm8.", ".$df.", ".$lnLm7.", ".$lnLm8.", ".$chivalue.", ".$pvalue.",";
	    #$csv_table = $csv_table.$gene.", ".$kappam7.", ".$kappam8.", ".$npm7.", ".$npm8.", ".$df.", ".$lnLm7.", ".$lnLm8.", ".$chivalue.", ".$pvalue;
	    my $M8FILE;
	    open(M8, $element);
	    {
		local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
		$M8FILE = <M8>; #Stores contents of BLAST file into a scalor
	    }
	    #print $M8FILE;
	    my ($rm, $BEBelement);
	    my ($BEBscores, $rm2);
	    ($rm, $BEBelement) = split(/Bayes\sEmpirical\sBayes/, $M8FILE, 2); #For BEB score later in script
	    ($BEBscores, $rm2) = split(/The\sgrid/, $BEBelement, 2); #BEBscores now in $BEBscores
	    chomp($BEBscores);
	    chomp($BEBscores);
	    print $BEBscores;
	    my $BEBsummary = $gene."_BEB_scores.txt";
	    open my $OUT, ">", $BEBsummary or die("Can't open file. $!");
	    print $OUT $BEBscores; #output BEB scores for gene to seperate file
	    close $OUT;
	    my @BEB_Array = split("\n",$BEBscores);
	    foreach my $BEB(@BEB_Array){
		if ($BEB =~ m/[\s]+([0-9]+)\s([A-Z])[\s]+([0-9]\.[0-9]+[\*]+)[\s]+([0-9]\.[0-9]+\s\+\-\s[0-9]\.[0-9]+)/){
		    my $pos = $1;
		    my $AA = $2;
		    my $wpvalue = $3;
		    my $dnds = $4;
		    my $BEBs = $pos.", ".$AA.", ".$wpvalue.", ".$dnds.",";
		    $csv_table = $csv_table.$stats.$BEBs.$ontology;
		}
	    } if ($csv_table !~ m/$gene/g){
		my $BEBs = "n/a, n/a, n/a, n/a, ";
		$csv_table = $csv_table.$stats.$BEBs.$ontology;
	    }
	}
    }
}
print "\Done:\n";
print $csv_table;
my $outfile = "Site_model_selection_test_summary.csv";
open my $FILE, ">", $outfile or die("Can't open file. $!");
print $FILE $csv_table;
close $FILE;
