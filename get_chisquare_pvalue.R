#!/usr/bin/Rscript --vanilla

chi_pvalue <- function() {
args <- commandArgs(trailingOnly = TRUE)
chivalue <- args[1]
pvalue<-pchisq(as.numeric(as.character(chivalue)),df=2,lower.tail=FALSE)
writeLines(as.character(pvalue), "tmp_chivalue.txt")
}
chi_pvalue()


#pvalue_fdr<-p.adjust(as.numeric(as.character(pvalue)), method="fdr")
#pvalue_bnf <--p.adjust(as.numeric(as.character(pvalue)), method="bonferroni")