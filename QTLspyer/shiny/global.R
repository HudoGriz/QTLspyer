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
  "fastqc_td" = c("FastQC: Report on trimmed data", 0),
  "bqsr" = c("GATK-BQSR: Base Quality Score Recalibration", 1)
)
row.names(optional_tools) <- c("name", "value")

primal_processes <- get.processes()
