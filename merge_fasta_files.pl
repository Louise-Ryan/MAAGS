#!/usr/bin/perl

my $fasta_file_extension = $ARGV[0];
chomp $fasta_file_extension;
my @file_array = (<*$fasta_file_extension>);

my $Output_File = $ARGV[1];

foreach my $file(@file_array) {
    unless ($file eq $Output_File) {
	my $cmd = "cat $file >> $Output_File";
	print $cmd."\n";
	system("$cmd");
    }
}

print "\nFasta files merged to $Output_File\n";

exit;
