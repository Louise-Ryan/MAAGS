#Best-fit model: TIM3+F+R3 
#Best-fit model: K3P+I+G4
#JTT+I+G4, A1CF = 1-601
#JTTDCMut+F+G4, A3GALT2 = 602-953
open(IN, "Positions");
while(<IN>){
    if($_=~m/([\S]+)[\s]+([0-9]+)[\s]+([0-9]+)/){
	$gene=$1;
	$pos1=$2;
	$pos2=$3;
	$targetgene="";
	if($gene=~m/([\S]+)/){
#	if($gene=~m/([\S]+)\_NT/){
	    $targetgene=$1;
	}
#	print $targetgene."\n";
#	$gene=~s/\.fa//;
	$t1=$gene."\.log";
	$t2=$gene."\.fas\.log";
#	print $t1."\n";
	$model="";
#	print $t2."\n";
	if(-e $t1){
	    open(IN2, "$t1");
	    while(<IN2>){
		if($_=~m/Best\-fit[\s]*model\:[\s]*([\S]+)/){
		    $model=$1;
		    #    print $model."\n";
		}
	    }
	}
	elsif(-e $t2){
	    open(IN2, "$t2");
            while(<IN2>){
		if($_=~m/Best\-fit[\s]*model\:[\s]*([\S]+)/){
		    $model=$1;
		}
            }
	}
	else{
	    print "fucked\n";
	    print $gene."\n";
	    print $t1."\n".$t2."\n\n";
	    exit;
	}
	print $model."\, ".$targetgene." = ".$pos1."-".$pos2."\n";
    }
}
