#!/usr/bin/perl

my $Output_File = $ARGV[0];
my $fasta_file_extension = "fa";
my @file_array = (<*$fasta_file_extensio>);

foreach my $file(@file_array) {
    my $cmd = "cat $file >> $Output_File";
    print $cmd."\n";
    system("$cmd");
}

print "\nFasta files merged to $Output_File\n";

exit;
