All that that the user needs to provide is considered as input data and can be found under `QTLspyer\input`.

#### Sample sequence data

The sample sequence data should be put inside the `sample_data` folder. The data should be of `.fastq` format.
Process recognizes uncompressed or **gzip**-ed files. Sequences can be **pair-end** or **single-end**.

#### Reference data

Here the reference organism genome should be provided in `.fasta` format. Additionally a `.vcf` of known SNPs is required.

#### Annotation data

Here the organism `.gtf` data should be given. This enables gene mapping to the _snp_ plots.

#### Adapters

Provided adapters in `.fasta` will be trimmed from the sample sequences.
