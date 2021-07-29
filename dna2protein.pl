my $filename=$ARGV[0];
chomp $filename;
my @array=(<*$filename>);
foreach $file(@array){
    print $file."\n";
    open(DNAFILE, $file) or die "Cannot open file \"$file\"\n\n";
    @DNA = <DNAFILE>;
    close DNAFILE;
    $DNA = join('', @DNA);
    @DNA=[];
    @DNA=split(/\>/,$DNA);
    if($file=~m/(.*)/){
        $outfile=$1.".protein";
	print $outfile."\n";
    }
    open(OUT, ">>$outfile");
    for($l=1;$l<scalar(@DNA);$l++){
	$seq=$DNA[$l];
	if($seq=~m/(.*)\n([A-Za-z\s\n\-]+)/){
	    $head=">".$1."\n";
	    $curseq=$2;
	}
	$y=$curseq;
	$curseq =~ s/\s//g;
	if($curseq=~m/atgc/){
	    $curseq=~tr/atgc/ATGC/;
	}
	my $protein='';
	my $codon;
	if($curseq=~m/____/){
	}
	else{
	    for(my $i=0;$i<(length($curseq)-2);$i+=3)
	    {
		$codon=substr($curseq,$i,3);
		$protein.=&codontoaa($codon);
	    }
	    print OUT "$head$protein\n";
	}
    }
    close OUT;
    close DNAFILE;
}
sub codontoaa{
    my($codon)=@_;
    $codon=uc $codon;
    my(%g)=('TCA'=>'S','TCC'=>'S','TCG'=>'S','TCT'=>'S','TTC'=>'F','TTT'=>'F','TTA'=>'L','TTG'=>'L','TAC'=>'Y','TAT'=>'Y','TAA'=>'*','TAG'=>'*','TGC'=>'C','TGT'=>'C','TGA'=>'*','TGG'=>'W','CTA'=>'L','CTC'=>'L','CTG'=>'L','CTT'=>'L','CCA'=>'P','CCC'=>'P','CCG'=>'P','CCT'=>'P','CAC'=>'H','CAT'=>'H','CAA'=>'Q','CAG'=>'Q','CGA'=>'R','CGC'=>'R','CGG'=>'R','CGT'=>'R','ATA'=>'I','ATC'=>'I','ATT'=>'I','ATG'=>'M','ACA'=>'T','ACC'=>'T','ACG'=>'T','ACT'=>'T','AAC'=>'N','AAT'=>'N','AAA'=>'K','AAG'=>'K','AGC'=>'S','AGT'=>'S','AGA'=>'R','AGG'=>'R','GTA'=>'V','GTC'=>'V','GTG'=>'V','GTT'=>'V','GCA'=>'A','GCC'=>'A','GCG'=>'A','GCT'=>'A','GAC'=>'D','GAT'=>'D','GAA'=>'E','GAG'=>'E','GGA'=>'G','GGC'=>'G','GGG'=>'G','GGT'=>'G','NNN'=>'X','GCN'=>'A','RAY'=>'B','TGY'=>'C','GAY'=>'D','GAR'=>'E','TTY'=>'F','GGN'=>'G','CAY'=>'H','ATH'=>'I','AAR'=>'K','TTR'=>'L','CTN'=>'L','YTR'=>'L','AAY'=>'N','CCN'=>'P','CAR'=>'Q','CGN'=>'R','AGR'=>'R','MGR'=>'R','TCN'=>'S','AGY'=>'S','ACN'=>'T','GUN'=>'V','TAY'=>'Y','SAR'=>'Z','TAR'=>'*','TRA'=>'*', '---'=>'-');
    if(exists $g{$codon})
    {
	return $g{$codon};
    }
    else
    {
	return "X";
    }
}



####Directory output
$Directory_name = <STDIN>;
chomp $Directory_name;

system("mkdir $Directory_name");
system("mv *.protein $directoryname");



