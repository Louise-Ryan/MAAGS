#!/usr/bin/perl

print "\nMerging maker predictions to output files ..\n\n";

my $GENOME;
#1 Store genome accession:
use Cwd qw(cwd);
my $dir = cwd;
$dir =~ s/\///g;
print "\n$dir\n";
if ($dir =~ m/.*(GC.*?_.*?\.\d).*/i) {
    $GENOME = $GENOME.$1;
}

#Maker Proteins 
my $Maker_proteins_extension = "maker.proteins.fasta";
my $Maker_proteins = "maker_proteins_fasta";
my $Maker_proteins_file = $GENOME."_".$Maker_proteins;

#Maker transcripts
my $Maker_transcripts_extension = "maker.transcripts.fasta";
my $Maker_transcripts = "maker_transcripts_fasta";
my $Maker_transcripts_file = $GENOME."_".$Maker_transcripts;

#Maker abinitio proteins
my $Maker_AbInitio_proteins_extension = "maker.non_overlapping_ab_initio.proteins.fasta";
my $Maker_AbInitio_proteins = "maker_non_overlapping_ab_initio_proteins_fasta";
my $Maker_AbInitio_proteins_file = $GENOME."_".$Maker_AbInitio_proteins;

#Maker abinitio transcripts
my $Maker_AbInitio_transcripts_extension = "maker.non_overlapping_ab_initio.transcripts.fasta";
my $Maker_AbInitio_transcripts = "maker_non_overlapping_ab_initio_transcripts_fasta";
my $Maker_AbInitio_transcripts_file = $GENOME."_".$Maker_AbInitio_transcripts;

#Maker augustus proteins
my $Maker_Augustus_proteins_extension = "maker.augustus_masked.proteins.fasta";
my $Maker_Augustus_proteins = "augustus_masked_proteins_fasta";
my $Maker_Augustus_proteins_file = $GENOME."_".$Maker_Augustus_proteins;

#Maker augustus transcripts
my $Maker_Augustus_transcripts_extension ="maker.augustus_masked.transcripts.fasta";
my $Maker_Augustus_transcripts = "augustus_masked_transcripts_fasta";
my $Maker_Augustus_transcripts_file = $GENOME."_".$Maker_Augustus_transcripts;


#2 Merge_fasta_files.pl

#Maker proteins
system("merge_fasta_files.pl $Maker_proteins_extension $Maker_proteins_file");

#Maker transcripts
system("merge_fasta_files.pl $Maker_transcripts_extension $Maker_transcripts_file");

#Maker AbInitio proteins
system("merge_fasta_files.pl $Maker_AbInitio_proteins_extension $Maker_AbInitio_proteins_file");

#Maker AbInitio transcripts
system("merge_fasta_files.pl $Maker_AbInitio_transcripts_extension $Maker_AbInitio_transcripts_file");

#Maker Augustus proteins
system("merge_fasta_files.pl $Maker_Augustus_proteins_extension $Maker_Augustus_proteins_file");

#Maker Augustus transcripts
system("merge_fasta_files.pl $Maker_Augustus_transcripts_extension $Maker_Augustus_transcripts_file");


#3 Make raw files directory and move all raw files here

my $RAWDIR = "RAW_MAKER_FILES";
system("mkdir $RAWDIR");
system("mv *.fasta $RAWDIR");

#4 Move protein files to directory

my $PROT = "PROTEIN_DIRECTORY";
system("mkdir $PROT");
system("mv *$Maker_proteins $PROT");
system("mv *$Maker_AbInitio_proteins $PROT");
system("mv *$Maker_Augustus_proteins $PROT");

print "Done!\n";

exit;
