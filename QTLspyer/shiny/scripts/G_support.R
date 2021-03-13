# Support functions for G analysis.

getG <- function(LowRef, HighRef, LowAlt, HighAlt) {
  exp <- c(
    (LowRef + HighRef) * (LowRef + LowAlt) / (LowRef + HighRef + LowAlt + HighAlt),
    (LowRef + HighRef) * (HighRef + HighAlt) / (LowRef + HighRef + LowAlt + HighAlt),
    (LowRef + LowAlt) * (LowAlt + HighAlt) / (LowRef + HighRef + LowAlt + HighAlt),
    (LowAlt + HighAlt) * (HighRef + HighAlt) / (LowRef + HighRef + LowAlt + HighAlt)
  )
  obs <- c(LowRef, HighRef, LowAlt, HighAlt)

  G <-
    2 * (rowSums(obs * log(
      matrix(obs, ncol = 4) / matrix(exp, ncol = 4)
    )))
  return(G)
}

tricubeStat <- function(POS, Stat, windowSize = 2e6, ...) {
  if (windowSize <= 0) {
    stop("A positive smoothing window is required")
  }
  stats::predict(locfit::locfit(Stat ~ locfit::lp(POS, h = windowSize, deg = 0), ...), POS)
}

getPvals <-
  function(Gprime,
           deltaSNP = NULL,
           outlierFilter = c("deltaSNP", "Hampel"),
           filterThreshold) {
    if (outlierFilter == "deltaSNP") {
      if (abs(filterThreshold) >= 0.5) {
        stop("filterThreshold should be less than 0.5")
      }

      message("Using deltaSNP-index to filter outlier regions with a threshold of ", filterThreshold)
      trimGprime <- Gprime[abs(deltaSNP) < abs(filterThreshold)]
    } else {
      message("Using Hampel's rule to filter outlier regions")
      lnGprime <- log(Gprime)

      medianLogGprime <- median(lnGprime)

      # calculate left median absolute deviation for the trimmed G' prime set
      MAD <-
        median(medianLogGprime - lnGprime[lnGprime <= medianLogGprime])

      # Trim the G prime set to exclude outlier regions (i.e. QTL) using Hampel's rule
      trimGprime <-
        Gprime[lnGprime - median(lnGprime) <= 5.2 * MAD]
    }

    no_NA <- na.omit(trimGprime)
    medianTrimGprime <- median(no_NA)

    # estimate the mode of the trimmed G' prime set using the half-sample method
    message("Estimating the mode of a trimmed G prime set using the 'modeest' package...")
    modeTrimGprime <-
      modeest::mlv(x = no_NA, bw = 0.5, method = "hsm")[1]

    muE <- log(medianTrimGprime)
    varE <- abs(muE - log(modeTrimGprime))
    # use the log normal distribution to get pvals
    message("Calculating p-values...")
    pval <-
      1 - plnorm(
        q = Gprime,
        meanlog = muE,
        sdlog = sqrt(varE)
      )

    return(pval)
  }

getFDRThreshold <- function(pvalues, alpha = 0.01) {
  sortedPvals <- sort(pvalues, decreasing = FALSE)
  pAdj <- p.adjust(sortedPvals, method = "BH")
  if (!any(pAdj < alpha)) {
    fdrThreshold <- NA
  } else {
    fdrThreshold <- sortedPvals[max(which(pAdj < alpha))]
  }
  return(fdrThreshold)
}
