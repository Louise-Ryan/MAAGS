#!/usr/bin/perl -w
my $file_extension = "\.fa";
my @filename_array = (<*$file_extension>);

my $Merged_file = $ARGV[0];

foreach $file(@filename_array) {
    system("cat $file >> $Merged_file");
}

exit;

