library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(shinyWidgets)
library(QTLseqr)
library(ggplot2)
library(shinycssloaders)
library(htmlwidgets)
library(randomcoloR)
library(shinyBS)
library(markdown)
library(rtracklayer)

library(promises)
library(future)
plan(multisession)

files.sources <- list.files("scripts", full.names = TRUE)
sapply(files.sources, source)

optional_tools <- data.frame(
  stringsAsFactors = FALSE,
  "fastqc_rd" = c("FastQC: Report on raw data", 0),
  "trimming" = c("BBduk: trim reads", 0),
  "fastqc_td" = c("FastQC: Report on trimmed data", 0)
)
row.names(optional_tools) <- c("name", "value")

pipeline_scripts <- list.files(
  path = "../variant_calling/", pattern = "\\_script.py$"
  )
names(pipeline_scripts) <- c(
  "GATK best practice (Pipeline with BQSR)",
  "Light weight (Pipeline without BQSR)")

pipelines_elements <- list(
  "no_bqsr_variant_calling_script.py" = c(
    "Trimming", "Mapping", "Read Groups Processing",
    "Marking Duplicates", "Variant Calling", "Combine GVCFs",
    "Filtering Out SNPs", "Quality Filtering VCF", "Variants To Table"
  ),
  "best_practice_germline_variant_discovery_script.py" = c(
    "Trimming", "Mapping", "Marking Duplicates", "Read Groups Processing",
    "Base Recalibration", "Variant Calling", "Combine GVCFs",
    "Filtering Out SNPs", "Variants To Table"
  )
)

primal_processes <- get.processes()
