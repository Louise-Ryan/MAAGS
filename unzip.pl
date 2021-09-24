#!/usr/bin/perl
system("for file in *.gz;do gunzip $file;done");
exit;
