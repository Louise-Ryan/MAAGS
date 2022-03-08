#!/usr/bin/perl
#system("conda activate ggtree_env");' This doesnt work but I NEED to add this to an sbatch or just do this locally for the script tp work. requires R and treeio.
open(IN, "GOs.txt"); #GOs is a text file with Gene, Ontology\n format.
my @GENES = <IN>;
close IN;

my $tsv_table = $tsv_table."Gene\tBranch\tClade\tSpecies\tRate\tdNdS\tLRT\tp-value\tCorrected p-value\tOntology\n"; #ABSREL
my $tsv_MEME = $tsv_MEME."Gene\tCodon\tPartition\talpha\tbeta\+\tp\+\tLRT\tEpisodic selection detected?\tPvalue\t\#branches\tcommon codon substitutions\tOntology\n";
foreach my $line(@GENES){
    my ($gene, $ontology) = split ("\,", $line, 2);
    my $branch;
    my $clade;
    my $species;
    my $corrected_pval;
    my $node;
    my $rate;
    my $dNdS;
    my $LRT;
    my $uncorrected_pval;
    my $branch_pval;
    my @BRANCHES = ();
    my @NODES = ();
    $gene =~ s/\n//g;
    $gene =~ s/\s//g;
    $ontology =~ s/\n//g;
    #print $gene."\n";
    my @GENE_ARRAY = (<$gene*>);
    foreach my $element(@GENE_ARRAY){
	if ($element =~ m/.*absrel\.txt/i){ #ABSREL FILE
	    print "Opening $element ...!\n";
	    open(ABSREL, $element);
	    while(<ABSREL>) {
		my $branch = "";
		my $corrected_pval = "";
		my $branch_pval = "";
		my $line = $_;
		if ($line =~ m/(.*)p\-value.*\=.*([0-9]+\.[0-9]+).*/i){
		    my $branch = $1;
		    my $corrected_pval = $2;
		    $branch =~ s/\*//g;
                    $branch =~ s/\,//g;
                    $branch =~ s/\s//g;
                    #print $branch."\n";
		    #print $corrected_pval."\n";
		    my $branch_pval = $branch."~".$corrected_pval;
		    push(@BRANCHES, $branch_pval);
		    if ($branch =~ m/Node.*/i){
			my $node = $branch;
			if($node !~ @NODES){
			    push(@NODES, $node);
			}
		    }
		}
	    }
	    close ABSREL;
	    my $species;
	    my $clade;
	    foreach my $val(@BRANCHES){
		my ($branch, $corrected_pval) = split("\~", $val);
		print $branch."\n";
                print $corrected_pval."\n";
		if ($branch =~ m/Node.*/i){
		    system(rm "subtree_tmp.tre");
		    foreach my $el(@GENE_ARRAY){
			if($el =~ m/.*\.ABSREL\.json/i){ #Get tree with node labels from JSON                                                        
			    my $regex = "\"trees\"\:{";
			    #my $cmd = "grep \Q$regex\E $el -A2 > tmp.txt";
			    #print $cmd."\n";
			    system("grep \Q$regex\E $el -A2 > tmp.txt");
			    open(AJSON, "tmp.txt");
			    {
				local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk
				my $treefile = <AJSON>;
				$treefile =~ s/\"trees\"\:\{//g;
				$treefile =~ s/\"0\"\:\"//g;
				$treefile =~ s/\s//g;
				$treefile =~ s/\"//g;
				$treefile =~ s/\}//g;
				$treefile = $treefile.";";
				my $treeout = "NodeTree.tre";
				open(FH, '>', $treeout) or die $!;
				print FH $treefile;
				close(FH);
			    }
			}
		    }
		    print "Rscript subtree_node.R NodeTree.tre $branch\n";
		    system("Rscript subtree_node.R NodeTree.tre $branch");
		    open(subtree, "subtree_tmp.txt");
		    {
			local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk                                     
			$clade = <subtree>;
			#$clade = s/\t//g;
			#chomp $clade;
			$species = $clade;
			$species =~ s/\(//g;
			$species =~ s/\)//g;
			$species =~ s/Node//g;
			$species =~ s/[0-9]+//g;
			$species =~ s/\;//g;
			#$species =~ s/\n//;
			#$species =~ s/\,/\n/g;
			#print $species."\n";
			#chomp $species;
		    }	
		    #chomp $clade;
		    $clade =~ s/\t//g;
		    $clade =~ s/\n//g;
		    $species =~ s/\t//g;
		    $species =~ s/\n//g;
		}
       		else{
		    $species = "n/a";
		    $clade = "n/a";
		}
		open(ABSREL, $element);
		my $grep = "Testing selected branches for selection";
		system("grep \Q$grep\E $element -A1000 > long.tmp");
		open(IN, "long.tmp");
		while(<IN>){
		    my $line = $_;
		    if ($line =~ m/\|.*\Q$branch\E\s+?\|\s+([0-9]).*?\|\s+([0-9]+\.[0-9]+.*\(.*\)).*?\|\s+([0-9]+\.[0-9]+).*?\|\s+([0-9]+\.[0-9]+).*?\|/i ||
			$line =~ m/\|.*\Q$branch\E\s+?\|\s+([0-9]).*?\|\s+(\>[0-9]+.*\(.*\)).*?\|\s+([0-9]+\.[0-9]+).*?\|\s+([0-9]+\.[0-9]+).*?\|/i){
			my $rate = $1;
			print "Rate: ".$rate."\n";
			my $dNdS = $2;
			print "dNdS: ".$dNdS."\n";
			my $LRT = $3;
			print "LRT: ".$LRT."\n";
			my $uncor_pval = $4;
			print "uncorrected p: ".$uncor_pval."\n";
			$tsv_table = $tsv_table.$gene."\t".$branch."\t".$clade."\t".$species."\t".$rate."\t".$dNdS."\t".$LRT."\t".$uncor_pval."\t".$corrected_pval."\t".$ontology."\n";
		    }
		}
	    }
	}
	elsif($element =~ m/.*MEME.txt/i){ #MEME
	    open(MEME, $element);
	    print "Opening $element ...\n";
	    while(<MEME>){
		my $line = $_;
		#print $line."\n";
		if ($line =~ m/\s+([0-9]+)\s+?\|\s+([0-9]+)\s+\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+?\|\s+(Yes)\,\sp\s\=\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+)\s+?\|\s+(\[.*[ATGCatgc]+)?\s.*/i){
	#	if ($line =~ m/\s+([0-9]+)\s+?\|\s+([0-9]+)\s+\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+?\|.*/i){ 
		    my $Codon = $1;
		   # print $Codon."\n";
		    my $Partition = $2;
		    #print $Partition."\n";
		    my $alpha = $3;
		   # print $alpha."\n";
		    my $beta = $4;
		   # print $beta."\n";
		    my $pplus=$5;
		   # print $pplus."\n";
		    my $LRT = $6;
		   # print $LRT."\n";
		    my $episodic_sel = $7;
		   # print $episodic_sel."\n";
		    my $pvalue = $8;
		   # print $pvalue."\n";
		    my $branches = $9;
		   # print $branches."\n";
		    my $common_subs = $10;
		   # print $common_subs."\n";
		   $tsv_MEME = $tsv_MEME.$gene."\t".$Codon."\t".$Partition."\t".$alpha."\t".$beta."\t".$pplus."\t".$LRT."\t".$episodic_sel."\t".$pvalue."\t".$branches."\t".$common_subs."\t".$ontology."\n";
		}
	    }
	}
    }    
}





system("rm tmp.txt");
system("rm subtree_tmp.txt");
system("rm NodeTree.tre");
system("rm long.tmp");
print "\Done:\n";
$tsv_out = "VomVoc_TOGA_ABSREL_results.tsv";
open(tsv, '>', $tsv_out) or die $!;
print(tsv $tsv_table);
close(tsv);
$tsv_MEME_out = "VomVoc_TOGA_MEME_results.tsv";
open(tsv, '>', $tsv_MEME_out) or die $!;
print(tsv $tsv_MEME);
close(tsv);

#print $csv_table;
