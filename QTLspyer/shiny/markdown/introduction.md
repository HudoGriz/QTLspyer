The goal of the tool is to make the process of a qtl analysis user friendly and easily repeatable.
The process is separated into two essential steps. The first step is to obtain **variant call format**
(`.vcf`) files. This is done running the **Germline short variant discovery** pipline by GATK.
The second step is to filter the data and to identify the _quantitative trait loci_ (QTL).
Both steps are simplified with a user interface made in **R** using **shiny**. For further
convince all tools and shiny server have been packed in to a **docker** container thus
eliminating the need for manual installation.
