#!/usr/bin/perl

#Requirements:
#system("conda activate ggtree_env");' This doesnt work but I NEED to add this to an sbatch or just do this locally for the script tp work. requires R and treeio.
#GOs.txt
#subtree_node.R
#runFDR.R

open(IN, "GOs.txt"); #GOs is a text file with Gene, Ontology\n format.
my @GENES = <IN>;
close IN;

my $tsv_table = $tsv_table."Gene\tBranch\tClade\tSpecies\tRate\tdNdS\tLRT\tp-value\tCorrected p-value\tOntology\n"; #ABSREL
my $tsv_MEME = $tsv_MEME."Gene\tCodon\tPartition\talpha\tbeta\+\tp\+\tLRT\tEpisodic selection detected?\tPvalue\tFDR Corrected Pvalue\t#branches\tcommon codon substitutions\tOntology\n"; #MEME
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
    my @SIGSITES = ();
    my @SIGBRANCHES = ();
    my @abUNCORR = ();
    my @SIGS = ();
    my $uncorrP;
    $gene =~ s/\n//g;
    $gene =~ s/\s//g;
    $ontology =~ s/\n//g;
    print "\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- \n";
    print "Results for $gene ...\n\n";
    my @GENE_ARRAY = (<$gene*>);
    open(OUT, ">n");
    foreach my $element(@GENE_ARRAY){
	if ($element =~ m/.*ABSREL.json/i){ #LOOP1: Get uncorrected pvalues for absrel and print to n
	    print "ABSREL results: \n";
	    open(IN, $element);
	    {
		local $/; #changes delimiter to nothing.
		my $ABSRELJ = (<IN>);
		my $regex = "\"0\"\:{";
		my @Ajson = split("\Q$regex\E", $ABSRELJ);
		shift(@Ajson);
		my $BRANCHES = shift(@Ajson); #this is the chunk we want to parse
		@BRANCHjson = split("\}\,",$BRANCHES); #split for each species
		foreach my $B(@BRANCHjson){
		    if ($B =~ m/\"(\S+)?\"\:\{/){ #pull branch info
			my $BRANCH = $1;
			push(@BRANCHES, $BRANCH); #push the branch info to array to be indexed later
			#print "Branch: ".$B."\n\n"; ####
			#print $BRANCH."\n"; ####
			if ($B =~ m/.*\"Uncorrected\sP\-value\"\:(.*)?\,/i || #get Pvalue (comma after)
			    $B =~ m/.*\"Uncorrected\sP\-value\"\:(\S+)/i){ #get Pvalue node (no comma after)
			    my $uncorrP = $1; #uncorrected pvalue
			    push(@abUNCORR, $uncorrP); #push uncorrected pvalue to array to be idexed later
			    print OUT $uncorrP."\n";
			    #print $uncorrP."\n"; #####
			}
		    }
		}
	    }
	    close IN;
	    close OUT;
	    open(IN5, "n");
	    `Rscript runFDR.R`; #FDR corrects pvalues and outputs file "x"with the corrected pvalues
	    open(IN2, "x"); #open file x
	    $res=""; #reset this
	    $c=0;
	    while(<IN2>){
		my $newp = ""; #reset
		my $line = $_;
		#print $line."\n";
		if($line=~m/\"[\s]+([0-9]+[\S]+)/ || #matches number + space
		   $line=~m/\"[\s]+([0-9]+)/){ #matches just number (single digits (eg. 0) didnt match without this)
		    $newp=$1; #FDR corrected pvalue
		    #print $newp."\n"; #####
		    if($newp<0.05){
			$res.=$line; #store signifigant hits in res
			$c++; #if any signifigant hits then c will be > 0
		    }
		}
	    }
	    close IN2;
	    if ($c > 0){ #if signifigant results
		@SIGS = split("\n", $res);
	    }
	    foreach my $val(@SIGS){ #for each signifigant pvalue
		my ($index, $corrPVAL) = split(/\"\s/, $val); #get the index to pull branch and uncorrected pvalues
		$index =~ s/\"//g; #index
		$index -=1; #index starts at 0 in perl
		my $branch = @BRANCHES[$index]; #pull branch info
		my $uncorrpval = @abUNCORR[$index]; #pull uncorrected pvalue info
		$sigresult = $branch."~".$uncorrpval."~".$corrPVAL; #append all useful info for use later on
		push(@SIGBRANCHES,$sigresult); #push to array
	    }
	    foreach my $el(@GENE_ARRAY){ #to get the dnds and lrt values we need the absrel.txt file
                if ($el =~ m/.*absrel\.txt/i){ #ABSREL FILE
                    my $grep = "Testing selected branches for selection";
                    system("grep \Q$grep\E $el -A1000 > long.tmp"); #grep the important section to long.tmp file
		}
	    }
	    foreach my $result(@SIGBRANCHES){ #foreach signifigant pvalue
		my $branch_match; #reset
		my ($branch, $uncorP, $corrected_pval) = split("~",$result,3);
		print "BRANCH: ".$branch."\n";
		print "UNCORRECTED PVALUE: ".$uncorP."\n";
		print "CORRECTED PVALUE:".$corrected_pval."\n";
		if (length($branch) < 32){ #if branch is less than 32 characters all is good
		    $branch_match = $branch;
		}
		if (length($branch) == 32){ #if branch is 32 characters, hyphy adds a "..." to the species name -_-
		    my $len = length($branch);
		    $branch_match = $branch."...";
		}
		if(length($branch) == 33){ #if branch is 33 characters, hyphy removes a letter and adds "..." to the species name -~-
		    my $len = length($branch);
		    $branch_match = substr($branch, 0, -1);
                    $branch_match = $branch_match."...";
		   # print "chopped 33: $branch_match\n";
		}
		if(length($branch) == 34){ #if branch is 34 characters, hyphy removes two letters and adds "..." to the species name -_-
                    my $len = length($branch);
                    $branch_match = substr($branch, 0, -2);
                    $branch_match = $branch_match."...";
                    #print "chopped 34:". $branch_match."\n";
		}
		if (length($branch) >= 35){ #if branch is >35 characters, hyphy removes the remaining letters, as well as three lettes so room for dots "..."
		    my $len = length($branch);
		    my $var = 35;
		    my $chop = $len - $var;
		    $chop += 3; #need to append three dots, so remove to get to length 32, then add 3 dots to be length 35
		    my $Chop = 0 - $chop;
		    $branch_match = substr($branch, 0, $Chop);
		    $branch_match = $branch_match."...";
		    print "chopped 35:". $branch_match."\n";
		}
		if ($branch =~ m/Node.*/i){ #if branch is a node, we want to pull the clade info from the json file using subtree_node.R
		    if(-e "subtree_tmp.tre"){
			system(rm "subtree_tmp.tre"); #rm tree if one exits
		    }
		    $branch_match = $branch_match." ";
		    print "BRANCH MATCH: $branch_match\n";#so node7 doesnt match node 77 node 777 etc ..
		    foreach my $file(@GENE_ARRAY){
			if($file =~ m/.*\.ABSREL\.json/i){ #Get tree with node labels from JSON                                                        
			    my $regex = "\"trees\"\:{";
			    system("grep \Q$regex\E $file -A2 > tmp.txt"); #grep the tree to a tmp file
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
				close(FH); #pull the tree and put into phylo format for treeio package
			    }
			}
		    }
		    print "Rscript subtree_node.R NodeTree.tre $branch\n"; #run the r script to pull the clade for the node of interest
		    system("Rscript subtree_node.R NodeTree.tre $branch");
		    open(subtree, "subtree_tmp.txt");
		    {
			local $/; #changes delimiter to nothing. Allows entire file to be read in as one chunk                                     
			$clade = <subtree>; #clade (with tree structure)
			$species = $clade; 
			$species =~ s/\(//g;
			$species =~ s/\)//g;
			$species =~ s/Node//g;
			$species =~ s/[0-9]+//g;
			$species =~ s/\;//g; #Species as a list
		    }	
		    $clade =~ s/\t//g;
		    $clade =~ s/\n//g;
		    $species =~ s/\t//g;
		    $species =~ s/\n//g;
		    print "CLADE: $clade \n";
		    print "SPECIES: $species \n";
		}
		else{ #if not a node, we dont need clade or species info since tip is a species
		    $species = "n/a";
		    $clade = "n/a";
		}
		open(IN4, "long.tmp"); #Open the results from absrel.txt file to pull dNdS and LRT values
		while(<IN4>){
		    my $line = $_;
		    if ($line =~ m/\Q$branch_match\E.*([0-9]+).*?\|\s+(\S+.*\(.*\)).*\|\s+(\S+).*?\|\s+([0-9]+\.[0-9]+).*?\|/i){
			#print $line."\n";
			my $rate = $1;
			print "Rate: ".$rate."\n";
			my $dNdS = $2;
			print "dNdS: ".$dNdS."\n";
			my $LRT = $3;
			print "LRT: ".$LRT."\n";
			$tsv_table = $tsv_table.$gene."\t".$branch."\t".$clade."\t".$species."\t".$rate."\t".$dNdS."\t".$LRT."\t".$uncorP."\t".$corrected_pval."\t".$ontology."\n"; #output signifigant hits to tsv file
		    }
		}
		close IN4;
	    }
	}
	elsif($element =~ m/.*\.MEME\.json/i){ #get the MEME results
	    if(-e "n"){
		`rm n`; #remove n if already exists from absrel loop
	    }
	    print "\n\nMEME results: \n";
	    open(IN, "$element");
	    open(OUT, ">n");
	    while(<IN>){
		if($_=~m/0\,[\s]+1\,[\s]+2\,[\s]+3\,[\s]+4\,[\s]+5\,[\s]+6\,[\s]+7\,[\s]+8/){
		}
		elsif($_=~m/\[[\S]+\,[\s]+[\S]+\,[\s]+[\S]+\,[\s]+[\S]+\,[\s]+[\S]+\,[\s]+[\S]+\,[\s]+([\S]+)\,[\s]+/){
		    print OUT $1."\n"; #gets the MEME uncorrected pvalues
		    #print "MemeP: $1\n";
		}
	    }
	    `Rscript runFDR.R`; #run FDR correction which outputs x file
	    open(IN2, "x"); #open x
	    $res="";
	    $c=0;
	    while(<IN2>){
		if($_=~m/\"[\s]+([0-9]+[\S]+)/ || 
                   $_=~m/\"[\s]+([0-9]+)/){ #important for single digits
		    $newp=$1;
		    if($newp<0.05){
			$res.=$_;
			$c++;
		    }
		}
	    }
	    if ($c >0){ #if any signifigant sites
		@SIGSITES = split("\n", $res); #signifigant sites
	    }
	}
	elsif($element =~ m/.*MEME.txt/i){ #open meme.txt to pull other values
	    open(MEME, $element);
	    #print "Opening $element ...\n";
	    while(<MEME>){
		my $line = $_;
		foreach my $site(@SIGSITES){
		    #print "Site: $site\n";
		    my ($codon, $corrPVAL) = split(/\"\s/, $site);
		    $codon =~ s/\"//g;
		    if ($line =~ m/.*$codon.*/i){
			if ($line =~ m/\s+([0-9]+)\s+?\|\s+([0-9]+)\s+\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+\|\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+\.[0-9]+)\s+?\|\s+(Yes)\,\sp\s\=\s+([0-9]+\.[0-9]+)\s+?\|\s+([0-9]+)\s+?\|\s+(\[.*[ATGCatgc]+)?\s.*/i){
			    my $Codon = $1;
			    print "CODON: $Codon\n";
			    my $Partition = $2;
			    my $alpha = $3;
			    my $beta = $4;
			    my $pplus=$5;
			    my $LRT = $6;
			    my $episodic_sel = $7;
			    my $pvalue = $8;
			    print "UNCORRECTED PVALUE: $pvalue\n";
			    print "CORRECTED PVAL: $corrPVAL\n";
			    my $branches = $9;
			    my $common_subs = $10;
			    $tsv_MEME = $tsv_MEME.$gene."\t".$Codon."\t".$Partition."\t".$alpha."\t".$beta."\t".$pplus."\t".$LRT."\t".$episodic_sel."\t".$pvalue."\t".$corrPVAL."\t".$branches."\t".$common_subs."\t".$ontology."\n"; #MEME sig sites tsv file
			}
		    }
		}
	    }    
	}
    }
}


print "\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- \n";

if(-e "n"){
   `rm n`;                                                                                                                                                                                                               
}
if(-e "x"){
    `rm x`;                                                                                                                                                                                                               
}
if(-e "tmp.txt"){
    `rm tmp.txt`;                                                                                                                                                                                                               
}
if(-e "subtree_tmp.txt"){
    `rm subtree_tmp.txt`;
}
if(-e "NodeTree.tre"){
    `rm NodeTree.tre`;
}
if(-e "long.tmp"){
    `rm long.tmp`;
}
$tsv_out = "VomVoc_TOGA_ABSREL_results_fdr.tsv";
open(tsv, '>', $tsv_out) or die $!;
print(tsv $tsv_table);
close(tsv);
$tsv_MEME_out = "VomVoc_TOGA_MEME_results_fdr.tsv";
open(tsv, '>', $tsv_MEME_out) or die $!;
print(tsv $tsv_MEME);
close(tsv);
print "Signifigant hits saved to:\n";
print "ABSREL: ".$tsv_out."\n";
print "MEME: ".$tsv_MEME_out."\n"
