#!/usr/bin/perl

open(IN, "gene_list.txt");
my @GENES = <IN>;
close IN;

my $csv_table = $csv_table."Gene, kappaM7, kappaM8, lnLM7, lnLM8, chivalue, pvalue\n";
foreach my $gene(@GENES){
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
		if ($line =~m/.*[0-9]+\s[A-Z]\s/){ #BEB scores position, amino acid, pr(w>1) ..
		}#BEB SCORES
		
	    }
	    my $df = $npm8 - $npm7;
	    print "df: $df\n";
	    my $chivalue = 2*($lnLm8 - $lnLm7);
	    print "Chi: ".$chivalue."\n";
	    system("Rscript get_chisquare_pvalue.R $chivalue"); #get p-value
	    open(tmp, "tmp_chivalue.txt");
	    my $pvalue = <tmp>;
	    $pvalue =~ s/\s//g;
	    $pvalue =~ s/\n//g;
	    print "pvalue: $pvalue\n";
	    $csv_table = $csv_table.$gene.", ".$kappam7.", ".$kappam8.", ".$lnLm7.", ".$lnLm8.", ".$chivalue.", ".$pvalue."\n";
	}
    }
}
print "\Done:\n";
print $csv_table;
my $outfile = "Site_model_selection_test_summary.csv";
open my $FILE, ">", $outfile or die("Can't open file. $!");
print $FILE $csv_table;
close $FILE;
