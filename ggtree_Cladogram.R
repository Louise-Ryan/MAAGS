library(ape)
library(aplot)
library(dplyr)
library(ggplot2)
library(grid)
library(magrittr)
library(methods)
library(purrr)
library(rlang)
library(rvcheck)
library(tidyr)
library(tidytree)
library(treeio)
library(utils)
library(scales)
library(ggtree)



ggtree_run <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  working_directory <- args[1]
  filename <- args[2]
  tree_name <- args[3]
  setwd(working_directory)
  tree <- read.tree(filename)
  ggtree(tree, branch.length = "none", color="black", size=1.5, linetype=1) + geom_nodepoint(colour="black",pch=21, size=11, fill = "white", alpha=0.9) +geom_nodelab(nudge_x = -0.08, size = 4.5, colour= "red")+  geom_tippoint(colour = "black") + geom_tiplab(size = 6) + xlim(NA,25)
  ggsave(filename = tree_name ,width = 20, height = 15 , units = "in" , limitsize = FALSE)
}

ggtree_run()





# ggtree argument branch.length="none"