#!/usr/bin/perl
use List::Util qw(max); #allows me to use the max(array) function

my $gene_list = "Gene_list.txt";

open(IN, $gene_list);
@gene_list = <IN>;
close IN;

my $fasta_file_extension = "fasta";
my @GENES = (<*$fasta_file_extension>);


foreach my $g(@gene_list){
    my($n, $length) = (0, 0);
    #my $break_loop = 0;
    my @LENGTHS = ();
    my @FILES = ();
    $g =~ s/\s//g;
    foreach my $file(@GENES){
	#print $file."\n";
	if ($file =~ m/$g\_.*\.fasta/i){
	    my($n, $length) = (0, 0);
	    open(IN, $file);
	    while(<IN>) {
		chomp;
		if(/^>/){
		    $n++;
		}else {
		    $length += length $_;
		}
	    }
	    my $mean_length = $length/$n; 
	    my $file_length = $file."|".$mean_length;
	    push (@LENGTHS, $mean_length);
	    push (@FILES, $file_length);
	}
    } 
    print $g.":\n";
    foreach my $l(@LENGTHS){
	print $l."\n";
    }
    my $longest_isoform = max(@LENGTHS);
    my @already= ();
    foreach my $f(@FILES){
	if ($f =~ m/.*\|(.*)/i) {
	    my $number = $1;
	}
	unless($number ~~ @already){
	    if ($f =~ m/(.*)\|$longest_isoform.*/i){
		my $longest_file = $1;
		push(@already, $number);
		print "This is longest: $longest_file\n";
		print $f."\n";
		system("cp $longest_file Longest_Isoforms");
	    }
	}
    }
}


