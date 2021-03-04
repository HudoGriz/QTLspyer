# function to calculate G statistics

# source("G_functions.R")

runGprimeAnalysis <-
  function(SNPset,
           windowSize = 1e6,
           outlierFilter = "deltaSNP",
           filterThreshold = 0.1, 
           ...)
  {
    message("Counting SNPs in each window...")
    SNPset <- SNPset %>%
      dplyr::group_by(CHROM) %>%
      dplyr::mutate(nSNPs = countSNPs_cpp(POS = POS, windowSize = windowSize))
    
    message("Calculating tricube smoothed delta SNP index...")
    SNPset <- SNPset %>%
      dplyr::mutate(tricubeDeltaSNP = tricubeStat(POS = POS, Stat = deltaSNP, windowSize, ...))
    
    message("Calculating G and G' statistics...")
    
    G = getG(
      LowRef = SNPset$AD_REF.LOW,
      HighRef = SNPset$AD_REF.HIGH,
      LowAlt = SNPset$AD_ALT.LOW,
      HighAlt = SNPset$AD_ALT.HIGH
    )
    
    Gprime = tricubeStat(
      POS = SNPset$POS,
      Stat = G,
      windowSize = windowSize,
      ...
    )
    
    SNPset$G <- G
    SNPset$Gprime <- Gprime
    
    SNPset$pvalue <- getPvals(
      Gprime = SNPset$Gprime,
      deltaSNP = SNPset$deltaSNP,
      outlierFilter = outlierFilter,
      filterThreshold = filterThreshold
    )
    
    SNPset$negLog10Pval <- -log10(SNPset$pvalue)
    SNPset$qvalue <- p.adjust(p = SNPset$pvalue, method = "BH")
    
    return(as.data.frame(SNPset))
  }
