# Functions needed for manipulating selected genes.

filter_annotation <- function(selected_gene, anno) {
  # Selected gene

  gtf_df <- anno$gtf

  right_annotation <- gtf_df[selected_gene == gtf_df$gene_name, ]
  right_annotation <- right_annotation[!is.na(right_annotation$gene_name), ]

  position <- unique(
    right_annotation[,
      c("nCHROM", "seqnames", "start", "end", "width", "strand", "gene_id",
        "gene_name")
    ]
  )
  position$start <- as.numeric(position$start)
  position$gene <- selected_gene
  position$CHROM <- position$seqnames

  return(position)
}

mark_gene <- function(session, p, position, chromosomes, col) {
  # Mark selected gene on plot

  plotlyProxy(p, session) %>%
    plotlyProxyInvoke("addTraces", list(
      name = position$gene,
      x = c(
        position$start, position$start, position$end, position$end,
        position$start
      ),
      y = c(-10000000, 10000000, 10000000, -10000000, -10000000),
      fill = "toself",
      type = "scatter",
      mode = "lines",
      xaxis = "x",
      yaxis = paste0("y", position$nCHROM),
      hoverinfo = "text",
      hovertext = c(
        paste(
          "Gene ID:", position$CHROM,
          "<br>Gene ID:", position$gene_id,
          "<br>Gene name:", position$gene,
          "<br>Start:", position$start,
          "<br>End:", position$end,
          "<br>Width:", position$width,
          "<br>Strand:", position$strand
        )
      ),
      hoveron = "points+fills",
      marker = list(
        "color" = col
      )
    ))
}

delete_gene <- function(session, p, gene, trace) {
  # Delete trace by name

  plotlyProxy(p, session) %>%
    plotlyProxyInvoke("deleteTraces", list(as.integer(trace + gene - 1)))
}
