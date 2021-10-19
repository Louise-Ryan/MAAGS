#!/usr/bin/Rscript --vanilla
library(ape)

remove_node <- function() {
	   args <- commandArgs(trailingOnly = TRUE)
	   working_directory <- getwd()
	   treename <- args[1]
	   drop_sp <- args[2]
	   setwd(working_directory);
	   tree <- read.tree(treename)
	   pruned_tree <-drop.tip(tree, drop_sp)
	   write.tree(pruned_tree, file = "trimmed_tree.tre")
}

remove_node()

