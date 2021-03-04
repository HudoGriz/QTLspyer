This pipeline can be run from teh first tab **Variant discovery**.
The page consists of a input box to the left and two output boxes to the right.
In the input boxes you have to provide an experiment name which is later used for
file naming of the results. Marker selection should be set accordingly to input sample name.
The reference **FASTA** file appears automatically after inserting the `.fasta` file into the folder `references`.
Advanced options can be toggled on or off for further user tailoring of the pipeline.
The steps in **pipeline includes** should be exclusively used for skipping steps
when running a failed pipeline again. The process will fail if a tool can not find output files from a previous step.

The command line for running the pipeline will be printed on top the progress report.
In the progress report window each tool will past its time status when finished.
The standard output of each tool can be observed in the **Standard output** box.


Both pipelines follow the **GATK best practice** instruction for germline short variant discovery.
The only difference is in the inclusion of base recalibration.

<img src="../www/germline_best_practice.png" width="700">

_Visual representation of the pipeline. The tools named on pages are used on each sample individually._
_Tools named outside are used on samples combined._
(Source: [GATK](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-))

### Tools

#### FastQC

FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput
sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your
data has any problems of which you should be aware before doing any further analysis
([source](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)).

FastQC can be run before trimming and after trimming. The following [manual](https://dnacore.missouri.edu/PDF/FastQC_Manual.pdf)
can help with the understanding of the output report.

#### BBduk

This is the software that is used for input sequence trimming. Trimming is an optional step and can be avoided by deselecting it.
In detail description about the tool can be found [here](https://dnacore.missouri.edu/PDF/FastQC_Manual.pdf).  
For questions about advanced options reference the [man-page](https://manpages.debian.org/testing/bbmap/bbduk.sh.1.en.html).

Single-end:  
```
bbduk.sh in={input1} out={trimmed} ref={adapters} ktrim={ktrim} qtrim={qtrim}  
trimq={trimq} overwrite=true k={k} mink={mink} hdist={hdist} tpe tbo ftm={ftm} chastityfilter={chastityfilter}  
minlen={minlen} threads={n_cores}
```  

Paired-end:  
```
bbduk.sh in={input1} in2={input2} out={trimmed} out2={trimmed2} ref={adapters} ktrim={ktrim} qtrim={qtrim}  
trimq={trimq} overwrite=true k={k} mink={mink} hdist={hdist} tpe tbo ftm={ftm} chastityfilter={chastityfilter}  
minlen={minlen} threads={n_cores}
```

#### Burrows-Wheeler Aligner (BWA)

**BWA-MEM** is used to align sample sequences to reference genome. Sepret variants are performed if sequences
are _single-end_ or _pair-end_. For more details reference [man pages](http://bio-bwa.sourceforge.net/bwa.shtml).

Single-end:  
`bwa mem -t {core} -M {reference} {input1}`  
Paired-end:  
`bwa mem -t {core} -M {reference} {input1} {input2}`

#### Mapping duplicates

Picards **MarkDuplicates** is used to locate and tag duplicate reads in alignment ( _BAM_ ) file,
where duplicate reads are defined as originating from a single fragment of DNA. Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard-)

`java -jar usr/picard/picard.jar MarkDuplicates INPUT={in1} OUTPUT={out} METRICS_FILE={out_duplicated_metric}`

#### Read groups

Picards **AddOrReplaceReadGroups** is used to assign all the reads in a file to a single new read-group.
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037226472-AddOrReplaceReadGroups-Picard-).

`java -jar ../usr/picard/picard.jar AddOrReplaceReadGroups INPUT={in1} OUTPUT={out} RGSM={sample} RGPU=none RGLB={ref_organism} RGPL=ILLUMINA`

#### Base recalibration

This is done in two steps. Fist GATKs **BaseRecalibrator** is used to generate a recalibration 
table based on various covariates. The default covariates are read group, reported quality score, machine cycle, and nucleotide context. 
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360036898312-BaseRecalibrator).

`java -jar {self.gatk} BaseRecalibrator -R {ref_fasta} -I {bam} --use-original-qualities -known-sites {ref_vcf} -O {bqsr_recal_table}`

In the second step GATKs **ApplyBQSR** is used to recalibrate the base qualities of the input reads based
 on the recalibration table produced by the BaseRecalibrator tool, and output a recelebrated BAM file.
 Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037055712-ApplyBQSR).

`java -jar {self.gatk} ApplyBQSR --add-output-sam-program-record -R {ref_fasta} -I {bam} --use-original-qualities --bqsr-recal-file {bqsr_recal_table} -O {out}`

#### Variant calling

GATKs **HaplotypeCaller** is used to call germline SNPs and indels via local re-assembly of haplotypes.
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037225632-HaplotypeCaller).

`java -jar {self.gatk} HaplotypeCaller -R {reference} -I {in1} -O {out} -ploidy {ploidy} -stand-call-conf {confidence}`

Confidence can be set in advance tool options.

#### Merging VCF files

GATKs **CombineGVCFs** is used to combine per-sample gVCF files produced by HaplotypeCaller into a multi-sample gVCF file.
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037053272-CombineGVCFs).

`java -jar {self.gatk} CombineGVCFs -V {input_comand} -R {reference} -O {out_merged}`

#### Variant selection

GATKs **SelectVariants** makes it possible to select a subset of variants based on various criteria in 
order to facilitate certain analyses. Here is it used for selection of **SNPs**.
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360037055952-SelectVariants).

`java -jar {self.gatk} SelectVariants -R {reference} -V {in1} -O {out} --select-type-to-include SNP'`

#### Variants to table

GATKs **VariantsToTable** is used to extract fields from a VCF file to a tab-delimited table.
Further information can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360036896892-VariantsToTable).

`java -jar {self.gatk} VariantsToTable -V {in1} -F CHROM -F POS -F REF -F ALT -GF DP -GF AD -GF GQ -GF PL -O {out}`
