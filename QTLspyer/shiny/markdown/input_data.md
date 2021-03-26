All data that the user needs to provide is considered as input data and should be contained in the `QTLspyer\input` folder.

    input
    ├── adapters                    # Expects adapters for sequence trimming (.fasta)
    ├── annotation                  # Expects genome annotation (.gtf)
    ├── references                  # Expects genome references (.fasta & .vcf)
    └── sample_data                 # Expects sample read sequences (.fastq)

#### Sample sequence data

The sample sequence data should be put inside the `sample_data` folder. The data should be of `.fastq` format.
Process recognizes uncompressed or **gzip**-ed files. Sequences can be **pair-end** or **single-end**. The names of each pool (bulk) need to be identical. No spaces in file names are allowed. If needed `_` can be used instead. Paired end reads need to be marked with `R1` (forward) and `R2` (reverse). The markings need to be separated from the name by `_` and be positioned on the end.  

Single-end example:

    - lowBulk.fastq.gz
    - highBulk.fastq.gz

Paired-end example:

    - sep_SRR12162861_R1.fastq.gz
    - sep_SRR12162861_R2.fastq.gz
    - sep_SRR12162862_R1.fastq.gz
    - sep_SRR12162862_R2.fastq.gz

#### Reference data

Here the reference organism genome should be provided in `.fasta` format. A reference genome for _Saccharomyces cerevisiae_ is already provided. The genome was taken from [NCBI](https://www.ncbi.nlm.nih.gov/genome/?term=Saccharomyces%20cerevisiae%5BOrganism%5D&cmd=DetailsSearch). The reference genome is used for read alignment. Additionally a `.vcf` of known SNPs for the studied organism is required. A generic file for _Saccharomyces cerevisiae_ is already provided. The file was obtained from [Ensembl](https://fungi.ensembl.org/Saccharomyces_cerevisiae/Info/Index).

#### Annotation data

Here the organism `.gtf` data should be given. This allows the user to select genes and mark its location on the genome plots. A generic annotation file for  _Saccharomyces cerevisiae_ is already provided. It was taken from [NCBI](https://www.ncbi.nlm.nih.gov/genome/?term=Saccharomyces%20cerevisiae%5BOrganism%5D&cmd=DetailsSearch)

#### Adapters

Provided adapters in `.fasta` will be trimmed from the sample sequences. An example file with Illumina adapters is already provided.
