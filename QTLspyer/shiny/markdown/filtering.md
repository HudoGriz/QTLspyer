Filtering is done based on the `QTLseqr` library for R.
The goal is to clean up the data in a way that will increase the posterior probability
of findings and decrease the false discovery rate. This can be done by 
filtering some of the low confidence SNPs and SNPs that may be in repetitive regions and
thus have inflated read depth.

To simplify the search for the best parameters, we can observe the four histograms.

The first histogram is of **read depths**. It should be condensed, without long tails into extreme lows or highs.

**Total reference allele frequency** holds information about number of QTL and their influence. The more the QTLs influence is the same, the more it resembles a normal distribution.

**Per-bulk SNP-index** is expected to contain two small peaks on each
end and most of the SNPs should be approximately normally distributed around 0.5 in an F2 population.
