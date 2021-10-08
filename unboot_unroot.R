#!/usr/bin/Rscript --vanilla
library(ape)

unboot_unroot <- function() {
	   args <- commandArgs(trailingOnly = TRUE)
	   working_directory <- args[1]
	   treename <-	     args[2]
	   setwd(working_directory);
	   tree <- read.tree(treename)
	   tree$node.label <- NULL
	   tree$edge.length <- NULL
	   unrooted_tree<-unroot(tree)
	   write.tree(tree, file = "MyTreeNoBoots.tre")
}

unboot_unroot()