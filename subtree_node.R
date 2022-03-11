suppressMessages(library(ape))
suppressMessages(library(treeio))

subtree_run <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  Tree <- args[1]
  Node <- args[2]
  tree <- read.tree(Tree)
  sub_tree <- tree_subset(tree, node = Node, levels_back = 0)
ape::write.tree(sub_tree, file='subtree_tmp.txt')
  
}

invisible(subtree_run())