# Functions that use support functions for creating plots.

plot_nSNPs <- function(SNPset, line) {
  var <- "nSNPs"

  p <- plot_base(SNPset, lab = "Number of SNPs in window", var = var)
  p <- plot_data(p, line = line, var = var)
  p <- plot_style(p)

  plotly_build(p)
}

plot_deltaSNP <- function(SNPset, line) {
  var <- "deltaSNP"
  var2 <- "tricubeDeltaSNP"

  p <- plot_base(SNPset, lab = "\u0394SNP index", var = var)

  p <- p + ylim(-1, 1) +
    geom_hline(yintercept = 0, color = "black", alpha = 0.4)

  ints_df <- dplyr::select(SNPset, CHROM, POS, dplyr::matches("CI_")) %>% tidyr::gather(key = "Interval", value = "value", -CHROM, -POS)
  delta_df <- dplyr::select(SNPset, CHROM, POS, dplyr::matches(var)) %>% tidyr::gather(key = "Interval", value = "value", -CHROM, -POS)
  tri_df <- dplyr::select(SNPset, CHROM, POS, dplyr::matches(var2)) %>% tidyr::gather(key = "Interval", value = "value", -CHROM, -POS)

  if (line) {
    p <- p + geom_line(data = ints_df, aes(x = POS, y = value, color = Interval)) +
      geom_line(data = ints_df, aes(x = POS, y = -value, color = Interval)) +
      geom_line(data = delta_df, aes(x = POS, y = value, color = Interval), alpha=0.5) +
      geom_line(data = tri_df, aes(x = POS, y = value, color = Interval))
  }

  if (!line) {
    p <- p + geom_line(data = ints_df, aes(x = POS, y = value, color = Interval)) +
      geom_line(data = ints_df, aes(x = POS, y = -value, color = Interval)) +
      geom_point(data = delta_df, aes(x = POS, y = value, color = Interval), alpha=0.5) +
      geom_point(data = tri_df, aes(x = POS, y = value, color = Interval))
  }

  color <- randomColor(length(unique(ints_df$Interval)), luminosity = "bright", hue="green")

  p <- p + facet_grid(CHROM ~ ., scales = "free_x", space = "free_x") +
    theme_minimal() +
    scale_color_manual("", values = c(color, "#3f9aff", "#222d32")) +
    theme(
      strip.text.y = element_text(angle = 0, size = 15),
      panel.spacing = unit(1, "mm"),
      plot.margin = unit(c(5, 30, 30, 20), "mm")
    )

  plotly_build(p)
}

plot_gprime <- function(SNPset, line, q) {
  var <- "Gprime"

  treshold <- get_treshold(SNPset, q = q)
  p <- plot_base(SNPset, lab = "G' value", var = var)
  p <- plot_data(p, line = line, var = var)
  p <- plot_treshold(p, plot = treshold$plot, treshold = treshold$g)
  p <- plot_style(p)

  plotly_build(p)
}

plot_pvalue <- function(SNPset, line, q) {
  var <- "negLog10Pval"

  treshold <- get_treshold(SNPset, q = q)
  p <- plot_base(SNPset, lab = "p-value", var = var)
  p <- plot_data(p, line = line, var = var)
  p <- plot_treshold(p, plot = treshold$plot, treshold = treshold$f)
  p <- plot_style(p)

  plotly_build(p)
}

plot_raw_snps <- function(data) {
  p <- ggplot(data = data) +
    scale_x_continuous(
      breaks = seq(
        from = 0, to = max(data$POS),
        by = 10^(floor(log10(max(data$POS))))
      ),
      labels = format_genomic(),
      name = "Genomic Position (Mb)"
    ) +
    ylim(-0.05, 1.05) +
    geom_hline(yintercept = 0.5, color = "black", alpha = 0.4) +
    geom_line(aes(x = POS, y = SNPindex.LOW, color = "Low"), alpha = 0.5) +
    geom_line(aes(x = POS, y = SNPindex.HIGH, color = "High"), alpha = 0.5) +
    scale_color_manual("", values = c("Low" = "#222d32", "High" = "#3f9aff")) +
    ylab("SNP index") +
    xlab("Genomic Position (Mb)") +
    facet_grid(CHROM ~ ., scales = "free_x", space = "free_x") +
    theme_minimal() +
    theme(
      strip.text.y = element_text(angle = 0, size = 15),
      panel.spacing = unit(0.09, "lines"),
      plot.margin = unit(c(5, 20, 20, 20), "mm")
    )

  plotly_build(p)
}
