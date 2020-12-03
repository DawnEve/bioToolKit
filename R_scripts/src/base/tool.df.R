# base/tool.df.R

###############################
# counts to cpm
###############################
# Tested. Passed.
getNormalizedCts <- function ( cts ) {
    #cts <- read.table ( ctsPath , header = T , as.is = T )
    apply ( cts , 2 , function ( x ) { log2 ( ( 10^6 ) * x / sum ( x ) + 1 ) })
}




###############################
# counts to FPKM, TPM
###############################
# refer: 
# https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/
# https://www.plob.org/article/16013.html

countToTpm <- function(counts, effLen){
    rate <- log(counts) - log(effLen)
    denom <- log(sum(exp(rate)))
    exp(rate - denom + log(1e6))
}

countToFpkm <- function(counts, effLen){
    N <- sum(counts)
    exp( log(counts) + log(1e9) - log(effLen) - log(N) )
}

fpkmToTpm <- function(fpkm) {
    exp(log(fpkm) - log(sum(fpkm)) + log(1e6))
}

countToEffCounts <- function(counts, len, effLen){
    counts * (len / effLen)
}



###
## An example
# cnts <- c(4250, 3300, 200, 1750, 50, 0)
# lens <- c(900, 1020, 2000, 770, 3000, 1777)
# countDf <- data.frame(count = cnts, length = lens)
 
## assume a mean(FLD) = 203.7
# countDf$effLength <- countDf$length - 203.7 + 1
# countDf$tpm <- with(countDf, countToTpm(count, effLength))
# countDf$fpkm <- with(countDf, countToFpkm(count, effLength))
# with(countDf, all.equal(tpm, fpkmToTpm(fpkm)))
# countDf$effCounts <- with(countDf, countToEffCounts(count, length, effLength))

# Q & A
# (1)As it reads above, “where FLD is the mean of the fragment length distribution which was learned from the aligned read.”

# (2) what is effective length?
# To make it easy, I’ll illustrate the concept of effective length with an example. Let’s say you are looking at a gene that is 100 nucleotides in length, and that each read is 30 exactly nucleotides long. Then, only reads starting at positions 1 through 71 in this gene can be found, because if you were to start sequencing at position 72 or further downstream then your read would be shorter than 30 (and you would not see it, if you follow the formula strictly). Thus, the effective length of this gene is 71 (because your target for sequencing is reduced to 71). Plugging the values in the formula, gene-length=100, mean-length-of-sequence-reads=30 (this is where it might become counterintuitive to some because there are surely sequence reads that are shorter, but this concept is statistic in nature, not strictly physical). Effective gene length is, then, 100-30+1 = 71.

