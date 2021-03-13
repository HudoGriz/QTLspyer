# Step functions for plotting.

format_genomic <- function(...) {
  # Format a vector of numeric values according
  # to the International System of Units.
  # http://en.wikipedia.org/wiki/SI_prefix
  #
  # Based on code by Ben Tupper
  # https://stat.ethz.ch/pipermail/r-help/2012-January/299804.html
  # Args:
  #   ...: Args passed to format()
  #
  # Returns:
  #   A function to format a vector of strings using
  #   SI prefix notation
  #

  function(x) {
    limits <- c(1e0, 1e3, 1e6)
    # prefix <- c("","Kb","Mb")

    # Vector with array indices according to position in intervals
    i <- findInterval(abs(x), limits)

    # Set prefix to " " for very small values < 1e-24
    i <- ifelse(i == 0, which(limits == 1e0), i)

    paste(
      format(round(x / limits[i], 1),
        trim = TRUE, scientific = FALSE
      )
      #  ,prefix[i]
    )
  }
}

plot_base <- function(SNPset, lab, var) {
  SNPset$colour <- var
  ggplot2::ggplot(data = SNPset) +
    ggplot2::scale_x_continuous(
      breaks = seq(
        from = 0, to = max(SNPset$POS),
        by = 10^(floor(log10(max(SNPset$POS))))
      ),
      labels = format_genomic(), name = "Genomic Position (Mb)"
    ) +
    ylab(lab)
}

plot_data <- function(p, line, var, ...) {
  if (line) {
    p <-
      p + ggplot2::geom_line(ggplot2::aes_string(x = "POS", y = var, colour = "colour"), ...)
  } else {
    p <-
      p + ggplot2::geom_point(ggplot2::aes_string(x = "POS", y = var, colour = "colour"), ...)
  }

  return(p)
}

plot_treshold <- function(p, plot, treshold) {
  if (plot) {
    p + ggplot2::geom_hline(
      ggplot2::aes(yintercept = treshold),
      color = "#3f9aff",
      size = 0.5,
      alpha = 0.4
    )
  } else {
    p
  }
}

plot_style <- function(p) {
  p + ggplot2::facet_grid(CHROM ~ ., scales = "free_x", space = "free_x") +
    theme_minimal() +
    scale_color_manual("", values = c("colour" = "#222d32", "#3f9aff", "#3f9aff")) +
    theme(
      panel.spacing = unit(0.09, "lines"),
      plot.margin = unit(c(5, 30, 30, 20), "mm")
    )
}

get_treshold <- function(SNPset, q) {
  fdrT <- getFDRThreshold(SNPset$pvalue, alpha = q)

  if (is.na(fdrT)) {
    plotThreshold <- FALSE
    logFdrT <- NULL
    GprimeT <- NULL
  } else {
    plotThreshold <- TRUE
    logFdrT <- -log10(fdrT)
    GprimeT <- SNPset[which(SNPset$pvalue == fdrT), "Gprime"]
  }
  return(treshold = list(g = GprimeT, f = logFdrT, plot = plotThreshold))
}
