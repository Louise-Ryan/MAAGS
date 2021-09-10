#!/usr/bin/Rscript --vanilla

library(dplyr)
library(ggplot2)
library(magrittr)
library(tidyr)

sort <- function() {
     args <- commandArgs(trailingOnly = TRUE)
     csvfilepath <- args[1]
     output <- args[2]
     csv <- read.csv(csvfilepath)
     table <- as_tibble(csv)
     sorted_table <- arrange(table, gene)
     write.csv(sorted_table, output)
     }

sort()