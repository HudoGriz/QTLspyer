The results of the analysis are in addition to plots also provided in form of three data tables. Each of them can be downloaded via the download button.
In the **SNPs** tab the statistic for each detected _SNP_ is provided. The second tab, **QTL - ∆SNP statistic** summarizes the chromosomal positions where _∆SNP_ was above the given threshold. The third tab, **QTL - Q statistic** summarizes the chromosomal positions where _Q'_ was above the given threshold. If no entries are given for the second and third data table it is because there are no chromosomal areas above the set threshold.

    - POS - genome position
    - REF - Reference nucleotide
    - ALT - Observed nucleotide
    - AD_REF.LOW - Allelic Depth of reference nucleotide in low bulk (pool)
    - AD_ALT.LOW - Allelic Depth of observed nucleotide in low bulk (pool) (DP.LOW - AD_REF.LOW)
    - DP.LOW - Read depth in low bulk
    - GQ.LOW - Genotype quality in low bulk
    - PL.LOW - Normalized Phred-scaled likelihoods of the genotypes considered in the variant record for low bulk
    - SNPindex.LOW - Single-nucleotide polymorphism index for low bulk (AD_ALT.LOW / DP.LOW)
    - AD_REF.HIGH - Allelic Depth of reference nucleotide in high bulk (pool)
    - AD_ALT.HIGH - Allelic Depth of observed nucleotide in low bulk (pool) (DP.HIGH - AD_REF.HIGH)
    - DP.HIGH - Read depth in high bulk
    - GQ.HIGH - Genotype quality in high bulk
    - PL.HIGH - Normalized Phred-scaled likelihoods of the genotypes considered in the variant record for high bulk
    - SNPindex.HIGH - Single-nucleotide polymorphism index for low bulk (AD_ALT.HIGH / DP.HIGH)
    - REF_FRQ - (AD_REF.HIGH + AD_REF.LOW) / (DP.HIGH + DP.LOW)
    - deltaSNP - Delta Single-nucleotide polymorphism index (SNPindex.HIGH - SNPindex.LOW)
    - tricubeDeltaSNP - Delta SNP value after applied tricube-smoothed kernel
    - minDP - Lowest read depth after read depth filtering around median depth
    - tricubeDP - Read depth after applied tricube-smoothed kernel
    - CI_X - Interval of X confidence value
    - G - G value
    - Gprime - G prime value
    - pvalue - p value
    - negLog10Pval - negative logarithm to ten p value
    - qvalue - q value

    - CHROM - The chromosome on which the region was identified
    - qtl - the QTL identification number in this chromosome
    - start - the start position on that chromosome, i.e. the position of the first SNP that passes the FDR threshold
    - end - the end position
    - length - the length in base pairs from start to end of the region
    - nSNPs - the number of SNPs in the region
    - avgSNPs_Mb - the average number of SNPs/Mb within that region
    - peakDeltaSNP - the ∆(SNP-index) value at the peak summit
    - posPeakDeltaSNP - the position of the absolute maximum tricube-smoothed deltaSNP-index
    - maxGprime - the max G’ score in the region
    - meanGprime - the average G0 score of that region
    - posMaxGprime - the genomic position of the maximum G’ value in the QTL
    - sdGprime - the standard deviation of G0 within the region
    - AUCaT - the Area Under the Curve but above the Threshold line, an indicator of how significant or wide the peak is
    - meanPval - the average p-value in the region
    - meanQval - the average adjusted p-value in the region


    


