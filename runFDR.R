tab<-read.table(file="n", header=FALSE)
p.adjust(tab[,1],method="fdr")
newtab<-p.adjust(as.numeric(as.character(tab[,1])),method="fdr")
write.table(newtab,file="x") 
