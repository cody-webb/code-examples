#install.packages("tidyverse")
library(ggplot2)

diff_data <- read.delim("gene_exp.diff", sep="\t", header = T, as.is = T)
#lfc_all <- data.frame(lfc=diff_data$log2.fold_change.)

diff_data_sig <- diff_data[which(diff_data$significant=="yes"),]
#lfc_sig <- data.frame(lfc=diff_data_sig$log2.fold_change.)

ggplot(diff_data, aes(x=log2.fold_change.)) + geom_histogram(binwidth=0.5, fill="#800000",
                                                             color="#000000") + ggtitle("Log2 FC for All Genes")+ xlim(-10,10) +xlab("Log2 Fold Change") + ylab("Frequency")

ggplot(diff_data_sig, aes(x=log2.fold_change.)) + geom_histogram(binwidth=0.5, fill="#800000",color="#000000") + ggtitle("Log2 FC for Significant Genes")+ xlim(-10,10) +xlab("Log2 Fold Change") + ylab("Frequency")