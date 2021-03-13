#!/usr/bin/env python3
import argparse
import sys

from tools import QtlTolls


parser = argparse.ArgumentParser(
    prog='QTL analysis'
)

parser.add_argument('--markerPosition', '-m', default=1,
                    help='Number of elements sepereted by underscore in sample name to use as a marker.', type=int)

parser.add_argument('--experimentName', '-exn',
                    help='Name of the experiment (for file naming).', type=str)

parser.add_argument('--Reference', '-r',
                    help='Name of the reference fasta file.', type=str)
parser.add_argument('--ReferenceName', '-rn',
                    help='Name of the reference organism.', type=str)
parser.add_argument('--Adapters', '-ad',
                    help='File name with adapters.', type=str)
parser.add_argument('--ReferenceVCF', '-rvcf',
                    help='File name of reference VCF file.', type=str)

parser.add_argument('--SeqSingle', '-ss',
                    help='The sample sequences single.',  default="FALSE", type=str)

parser.add_argument('--runFastqcPreTrim', default=0,
                    help='Run FastQC on reads before trimming.', type=int)
parser.add_argument('--runBBduk', default=0,
                    help='Run BBduk for read trimming.', type=int)
parser.add_argument('--runFastqcPostTrim', default=0,
                    help='Run FastQC on reads after trimming.', type=int)

parser.add_argument('--Trimming', '-t',
                    help='Pipeline to include trimming.', default=0, type=int)
parser.add_argument('--Mapping', '-map',
                    help='Pipeline to include mapping.', default=0, type=int)
parser.add_argument('--MarkingDuplicates', '-md',
                    help='Pipeline to include marking duplicates.', default=0, type=int)
parser.add_argument('--ReadGroupsProcessing', '-rgp',
                    help='Pipeline to include read grouping.', default=0, type=int)
parser.add_argument('--BaseRecalibration', '-brec',
                    help='Pipeline to include base recalibration.', default=0, type=int)
parser.add_argument('--VariantCalling', '-vc',
                    help='Pipeline to include variant calling.', default=0, type=int)
parser.add_argument('--CombineGVCFs', '-cg',
                    help='Pipeline to include variant calling.', default=0, type=int)
parser.add_argument('--FilteringOutSNPs', '-fos',
                    help='Pipeline to include filtering out SNPs.', default=0, type=int)
parser.add_argument('--VariantsToTable', '-vtt', help='Pipeline to include .vcf to table transformation.', default=0,
                    type=int)

# Toll settings
# BBduk
parser.add_argument('--Bbduk_n_cores', '-BB_cor',
                    help='Cores BBduk.sh should use when trimming.', default=8, type=int)
parser.add_argument('--Bbduk_ktrim', '-BB_kt',
                    help="Trim reads to remove bases matching reference k-mers. Values: f (don't trim), "
                         "r (trim to the right), l (trim to the left).",
                    default='r', type=str)
parser.add_argument('--Bbduk_qtrim', '-BB_qt', help='Trim read ends to remove bases with quality below trimq.',
                    default='r', type=str)
parser.add_argument('--Bbduk_trimq', '-BB_tq', help='Regions with average quality BELOW this will be trimmed.',
                    default=20, type=int)
parser.add_argument('--Bbduk_k', '-BB_k',
                    help='K-mer length used for finding contaminants. Contaminants shorter than k will not be found. '
                         'k must be at least 1.',
                    default=23, type=int)
parser.add_argument('--Bbduk_mink', '-BB_mk',
                    help='Look for shorter k-mers at read tips down to this length, when k-trimming or masking.',
                    default=11, type=int)
parser.add_argument('--Bbduk_hdist', '-BB_hd',
                    help='Maximum Hamming distance for ref k-mers (subs only). Memory use is proportional to '
                         '(3*K)^hdist.',
                    default=1, type=int)
parser.add_argument('--Bbduk_ftm', '-BB_ftm',
                    help='If positive, right-trim length to be equal to zero, modulo this number.',
                    default=5, type=int)
parser.add_argument('--Bbduk_chastityfilter', '-BB_cf',
                    help='Remove reads with unexpected barcodes if barcodes is set.',
                    default='f', type=str)
parser.add_argument('--Bbduk_minlen', '-BB_ml',
                    help='Reads shorter than this after trimming will be discarded. Pairs will be discarded if both '
                         'are shorter.',
                    default=50, type=int)

# HaplotypeCaller
parser.add_argument('--HaplotypeCaller_ploidy', '-HC_p',
                    help="Ploidy (number of chromosomes) per sample. For pooled data, set to (Number of samples in "
                         "each pool * Sample Ploidy).",
                    default=1, type=int)
parser.add_argument('--HaplotypeCaller_confidence', '-HC_c',
                    help="The minimum phred-scaled confidence threshold at which variants should be called.",
                    default=20, type=int)

# Parse arguments
args = parser.parse_args()

marker = args.markerPosition
fasta_ref = args.Reference
ref_org = args.ReferenceName
do_fastq_pretrim = args.runFastqcPreTrim
do_fastq_trim = args.runFastqcPostTrim

fasta_ref_file = f'input/references/{fasta_ref}'
vcf_ref_file = f'input/references/{args.ReferenceVCF}'

# Start process
qtl = QtlTolls()

qtl.populate_samples(marker_position=marker, single_reads=args.SeqSingle)

qtl.make_references(fasta_ref_file=args.Reference, ref_vcf=args.ReferenceVCF)

for sample in qtl.ori_samples:

    if args.SeqSingle == "TRUE":
        r = qtl.ori_samples[sample]

        r_name = r.split('.')[0]

        qtl.logger.info(f'read: {r}')

        if do_fastq_pretrim == 1:
            qtl.fastqc_single(status='untrimmed', sample=sample,
                              in1=f'{qtl.local_input}/{r}')

        if args.runBBduk == 1:
            trimmed = qtl.bbduk_single(
                sample=sample, r1_name=r_name, r1=f'{qtl.local_input}/{r}', exe=args.Trimming, adapters=args.Adapters,
                n_cores=args.Bbduk_n_cores, ktrim=args.Bbduk_ktrim, qtrim=args.Bbduk_qtrim, trimq=args.Bbduk_trimq,
                k=args.Bbduk_k, mink=args.Bbduk_mink, hdist=args.Bbduk_hdist, ftm=args.Bbduk_ftm,
                chastityfilter=args.Bbduk_chastityfilter, minlen=args.Bbduk_minlen
            )
        else:
            trimmed = f'{qtl.local_input}/{r}'

        if do_fastq_trim == 1:
            qtl.fastqc_single(status='trimmed', sample=sample, in1=trimmed)

        mapped = qtl.bwa_single(
            sample=sample, reference=fasta_ref_file, in1=trimmed, exe=args.Mapping, core=args.Bbduk_n_cores
        )

    else:
        r1 = qtl.ori_samples[sample]['R1']
        r2 = qtl.ori_samples[sample]['R2']

        r1_name = r1.split('.')[0]
        r2_name = r2.split('.')[0]

        qtl.logger.info(f'read1: {r1}, read2: {r2}')

        if do_fastq_pretrim == 1:
            qtl.fastqc(
                status='untrimmed', sample=sample,
                       in1=f'{qtl.local_input}/{r1}', in2=f'{qtl.local_input}/{r2}'
            )

        if args.runBBduk == 1:
            trimmed = qtl.bbduk(
                sample=sample, r1_name=r1_name, r2_name=r2_name, r1=f'{qtl.local_input}/{r1}',
                r2=f'{qtl.local_input}/{r2}', exe=args.Trimming, adapters=args.Adapters, n_cores=args.Bbduk_n_cores,
                ktrim=args.Bbduk_ktrim, qtrim=args.Bbduk_qtrim, trimq=args.Bbduk_trimq, k=args.Bbduk_k,
                mink=args.Bbduk_mink, hdist=args.Bbduk_hdist, ftm=args.Bbduk_ftm,
                chastityfilter=args.Bbduk_chastityfilter, minlen=args.Bbduk_minlen
            )
        else:
            trimmed = [f'{qtl.local_input}/{r1}', f'{qtl.local_input}/{r2}']

        if do_fastq_trim == 1:
            qtl.fastqc(
                status='trimmed', sample=sample,
                in1=trimmed[0], in2=trimmed[1]
            )

        mapped = qtl.bwa(
            sample=sample, reference=fasta_ref_file, in1=trimmed[0], in2=trimmed[1], exe=args.Mapping,
            core=args.Bbduk_n_cores
        )

    qtl.samtools_index(sample=sample, in1=mapped, exe=args.Mapping)

    mapped = qtl.picard_md(
        sample=sample, in1=mapped,
        exe=args.MarkingDuplicates
    )

    mapped = qtl.picard_rg(
        sample=sample, in1=mapped,
        ref_organism=ref_org, exe=args.ReadGroupsProcessing
    )

    mapped = qtl.gatk_BaseRecalibrator(
        sample=sample, bam=mapped, ref_fasta=fasta_ref_file, exe=args.BaseRecalibration,
        ref_vcf=vcf_ref_file)

    variants = qtl.gatk_haplotype_caller(
        sample=sample, in1=mapped, reference=fasta_ref_file, ploidy=args.HaplotypeCaller_ploidy,
        confidence=args.HaplotypeCaller_confidence, exe=args.VariantCalling
    )

vcfs = qtl.gatk_merge_vcfs(
    exe=args.CombineGVCFs, reference=fasta_ref_file, sample=args.experimentName)

filtered_variants = qtl.gatk_variant_selection(
    sample=args.experimentName, in1=vcfs, reference=fasta_ref_file,
    out=f'output/GATK/nonfiltered/{args.experimentName}.snps.vcf',
    parameters='SNP', exe=args.FilteringOutSNPs
)

variant_table = qtl.gatk_variants_to_table(
    sample=args.experimentName, in1=filtered_variants, exe=args.VariantsToTable
)

qtl.done()
