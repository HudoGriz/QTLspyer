#!/usr/bin/env python3
import sys

from argument_parser import parse
from tools import QtlTools


def main(args):
    """Call tools in assigned order."""

    fasta_ref = args.Reference
    ref_org = args.ReferenceName
    do_fastq_pretrim = args.runFastqcPreTrim
    do_fastq_trim = args.runFastqcPostTrim

    fasta_ref_file = f'input/references/{fasta_ref}'
    vcf_ref_file = f'input/references/{args.ReferenceVCF}'

    qtl = QtlTools()

    qtl.populate_samples(single_reads=args.SeqSingle)

    qtl.make_references(fasta_ref_file=args.Reference, ref_vcf=args.ReferenceVCF)

    for sample in qtl.ori_samples:

        if args.SeqSingle == "TRUE":
            r = qtl.ori_samples[sample]

            r_name = r.split('.')[0]

            qtl.logger.info(f'read: {r}')

            if do_fastq_pretrim == 1:
                qtl.fastqc_single(
                    status='untrimmed', sample=sample,
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
                        in1=f'{qtl.local_input}/{r1}', in2=f'{qtl.local_input}/{r2}')

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
                        in1=trimmed[0], in2=trimmed[1])

            mapped = qtl.bwa(
                sample=sample, reference=fasta_ref_file, in1=trimmed[0], in2=trimmed[1],
                core=args.Bbduk_n_cores, exe=args.Mapping
            )

        read_groups = qtl.picard_rg(
            sample=sample, in1=mapped, ref_organism=ref_org, exe=args.ReadGroupsProcessing)

        marked_duplicates = qtl.picard_md(
            sample=sample, in1=read_groups, exe=args.MarkingDuplicates)

        qtl.samtools_index(
            sample=sample, in1=marked_duplicates,
            exe=args.MarkingDuplicates)

        variants = qtl.gatk_haplotype_caller(
            sample=sample, in1=marked_duplicates, reference=fasta_ref_file, confidence=args.HaplotypeCaller_confidence,
            ploidy=args.HaplotypeCaller_ploidy, exe=args.VariantCalling
        )

    vcfs = qtl.gatk_merge_vcfs(
        exe=args.CombineGVCFs, reference=fasta_ref_file, sample=args.experimentName)

    selected_variants = qtl.gatk_variant_selection(
        sample=args.experimentName, in1=vcfs, reference=fasta_ref_file,
        out=f'{qtl.local_output}/GATK/nonfiltered/{args.experimentName}.snps.vcf',
        parameters='SNP', exe=args.FilteringOutSNPs
    )

    variant_table = qtl.gatk_variants_to_table(
        sample=args.experimentName, in1=selected_variants, exe=args.VariantsToTable)

    qtl.done()


if __name__ == '__main__': 
    parsed = parse()
    arguments = parsed.parse_args()
    
    main(args=arguments)
