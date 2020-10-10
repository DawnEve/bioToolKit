# base/tool.df.R

# Tested. Passed.
getNormalizedCts <- function ( cts ) {
    #cts <- read.table ( ctsPath , header = T , as.is = T )
    apply ( cts , 2 , function ( x ) { log2 ( ( 10^6 ) * x / sum ( x ) + 1 ) })
}

