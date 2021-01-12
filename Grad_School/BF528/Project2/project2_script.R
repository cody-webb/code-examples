#------------------------Part 1-------------------------------------


#------------------------------------Part 2 ------------------------
fpkm <- read.table("genes.fpkm_tracking", header = TRUE)

values <- fpkm$FPKM
x <- 0
y <- 0

for (m in 1:length(values)) {
  if (values[m] == 0) {
    values[m] = NA
    x <- x + 1
  }
  else if (values[m] > 40) {
    values[m] = NA
    y <- y + 1
  }
}

h_fpkm <- hist(values, breaks = 20, xlab= "Fragments Per Kilobase of Transcript per Million Mapped Reads", 
              ylim = c(0, 10000), main = "Histogram of FPKM Values")


