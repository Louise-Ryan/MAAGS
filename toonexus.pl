#open(IN, "Nucleotide_Partitions.txt");
open(IN, "NucPartitions.txt");
#open(IN, "100RFNucleotidePartitions.txt");
print "\#nexus\nbegin sets;\n";
$dataline;
#TVMe+I+G4, AC048338.1 = 162274-163914

while(<IN>){
    if($_=~m/([\S]+)\,[\s]+([\S]+)[\s]+\=[\s]+([\S]+)/){
	$a=$2;
	$b=$1;
	$c=$3;
	$a=~s/\-//g;
	print "\tcharset ".$a." = ".$c.";\n";
	
	$dataline.=$b.":".$a.", ";
    }
}
print "charpartition mine = ".$dataline.";\n";
