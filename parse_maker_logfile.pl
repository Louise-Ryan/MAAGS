#!/usr/bin/perl

my $maker_pred_dir = "/home/people/16386986/scratch/MAAGS_Vocalisation_Chemosensation/Genbank_VomVoc_annotation/Primate_Assemblies_03_Aug_21_GenBank_Rep_Genomes/Maker_predictions/";

my $file_extension = "master_datastore_index.log";
my @logfile_array = (<*$file_extension>);

foreach my $file(@logfile_array) {
    open(IN, $file);
    while(<IN>){
	my $line = $_;
	if ($line =~ m/.*?\s(.*)?\t.*FINISHED/i){
	    my $dir = $1;
	    #print $dir."\n";
	    my $dir_files = $dir."*fasta";
	    system("cp $dir_files $maker_pred_dir");
	}
    }
    if ($file =~ m/(GC.*)\_Contig/){
	my $genome = $1;
	print "\n\n".$genome."\n\n";
	my $gendir = $maker_pred_dir.$genome;
	system("mkdir $gendir");
	my $maker_pred_fasta= $maker_pred_dir."*fasta";
	system("mv $maker_pred_fasta $gendir");
    }
}

