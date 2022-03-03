my $file="primate_list";
open(IN, $file);
my @files = <IN>;
close IN;

#my @files = split("\n", $file);
foreach my $f(@files){
    $f =~ s/\n//g;
    print $f."\n";
    if ($f =~ m/(.*\_.*)\_.*/i){
	my $short_name = $1;
	print $short_name."\n";
	system("sed -i s/\Q$f\E/\Q$short_name\E/g Primate_Species_62_tree_shortnames.treefile");
    }
}
