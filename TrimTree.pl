#!/usr/bin/perl
#This script will grep species from alignment to txt file, compare this list with full species list (ARGV1) and remove missing species in alignment from the tree (ARGV2).

my @alignments=(<*NT>);
foreach my $aln(@alignments) {
    system("rename_headers_species_only.pl $aln");
    my $grep_cmd = "grep \"\>\" $aln";
    my $out = "Alignment_Species.txt";
    system("$grep_cmd >> $out");
    my $sed_cmd = "sed -ie s/\>//g $out";
    ststem("$sed_cmd");
}

my $file1 = $ARGV[0]; #List to compare to --> i.e RefSeq primate list
my $tree = $ARGV[1]; #Tree file name
my $file2 = $out;

open(IN, $file1);
@array1 = <IN>;
close IN;

open(IN2, $file2);
@array2 = <IN2>;
close IN2;

$array2 = join('', @array2);
$array2 =~ s/\n//g;

my $store;

foreach my $entry(@array1) {
    $entry =~ s/\n//g;
    $entry =~ s/\s//g;
    if ($array2 !~ m/$entry/i){
	print "\n".$entry."is not in gene alignment";
	$store = $store.$entry."\n";
    }elsif ($array2 =~ m/$entry/i) {
#	print "\n\n".$entry."eq";
    }else{
	print "\nwtf is going on?\n";
    }
}

my $outlist = "Species_to_trim_from_tree.txt";
open my $FILE, ">", $outlist or die("Can't open file. $!");
print $FILE $store;
close $FILE;

open(IN3, $outlist);
@array3 = <IN3>;
close IN3;


my $first_species = shift @array3; #Run removetip.R on first species to generate the 'trimmed_tree.tre' treefile from R script. 
system("Rscript removetip.R $tree $first_species");
print "\nRemoved $first_species from tree ..";
my $trimtree = "trimmed_tree.tre";

foreach my $species(@array3){ #Loop through remaining species and remove species from tree sequentially, overwriting tree with each run.
    system("Rscript removetip.R $trimtree $species");
    print "\nRemoved $species from tree ..";
}

exit;
