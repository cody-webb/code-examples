hist_data <- read.delim("bc_counts_total_awk.txt", sep="\t", as.is = T, header = F)

our_data <- matrix(nrow=1604234, ncol=2)

our_data[,1] = 1:1604234
our_data[,2] = 1:1604234 * 0

for (i in 1:21492) {
  idx <- hist_data[i,1]
  our_data[idx,2] <- hist_data[i,2]
}

hist(log10(rep(our_data[,1], our_data[,2])), 
     ylim = c(0,3500000),
     xlab = "(log10) Number of Times a Barcode was Found \n with Unique UMI in the Data Set",
     ylab = "Frequency of Barcode Frequency",
     main = "Barcode Frequency Histogram")

our_data[1:80000, 2] = 1:80000 * 0

hist(log10(rep(our_data[,1], our_data[,2])), 
     xlim = c(4.8, 6.2), ylim = c(0, 400),
     xlab = "(log10) Number of Times a Barcode was Found \n with Unique UMI in the Data Set",
     ylab = "Frequency of Barcode Frequency",
     main = "Barcode Frequency Histogram \n (With Data Removed)")
