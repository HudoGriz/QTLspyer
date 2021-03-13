# Import table created from vcf file.

get_annotation <- function(gtf_path) {
  # Get annotation
  gtf_path <- paste0("../input/annotation/", gtf_path)

  gtf <- rtracklayer::import(gtf_path)
  gtf_df <- as.data.frame(gtf)

  genes <- unique(gtf_df$gene_name)

  gtf_df$nCHROM <- as.numeric(factor(gtf_df$seqnames))

  return(
    list(
      gtf = gtf_df,
      chrom = chrom,
      genes = genes
    )
  )
}
