# Import tabel created from vcf file.

get_annotation <- function(
  gtf_path
  # chr_path = "../input/anotation/Crhomosome_anotation"
  
) {
  # Get anotation
  gtf_path <- paste0("../input/annotation/", gtf_path)
  
  gtf <- rtracklayer::import(gtf_path)
  gtf_df <- as.data.frame(gtf)
  
  genes <- unique(gtf_df$gene_name)
  
  gtf_df$nCHROM <- as.numeric(factor(gtf_df$seqnames))
  
  # chrom <- read.table(chr_path, sep = "\t", header = TRUE)
  # chrom$c_num <- c(1:length(chrom$Type))
  # chrom$Loc <- as.character(chrom$Loc)
  # chrom$Type <- as.character(chrom$Type)
  
  return(
    list(
      gtf = gtf_df,
      chrom = chrom,
      genes = genes
    )
  )
}