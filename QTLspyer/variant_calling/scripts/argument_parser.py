import argparse


def parse():
    """Parses all the arguments need to run the variant calling pipeline."""
    
    parser = argparse.ArgumentParser(
        prog='QTL analysis'
    )

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
    parser.add_argument('--ReadGroupsProcessing', '-rgp',
        help='Pipeline to include read grouping.', default=0, type=int)
    parser.add_argument('--MarkingDuplicates', '-md',
        help='Pipeline to include marking duplicates.', default=0, type=int)
    parser.add_argument('--VariantCalling', '-vc',
        help='Pipeline to include variant calling.', default=0, type=int)
    parser.add_argument('--CombineGVCFs', '-cg',
        help='Pipeline to include variant calling.', default=0, type=int)
    parser.add_argument('--FilteringOutSNPs', '-fos',
        help='Pipeline to include filtering out SNPs.', default=0, type=int)
    parser.add_argument('--QualityFilteringVCF', '-qfv', help='Pipeline to include quality filtering of VCFs.', default=0,
        type=int)
    parser.add_argument('--VariantsToTable', '-vtt', help='Pipeline to include .vcf to table transformation.', default=0,
        type=int)

    # Toll settings
    # BBduk
    parser.add_argument('--Bbduk_n_cores', '-BB_cor',
        help='Cores BBduk.sh should use when trimming.', default=8, type=int)
    parser.add_argument('--Bbduk_ktrim', '-BB_kt',
        help="Trim reads to remove bases matching reference k-mers. Values: f (don't trim), "
        "r (trim to the right), l (trim to the left).", default='r', type=str)
    parser.add_argument('--Bbduk_qtrim', '-BB_qt', help='Trim read ends to remove bases with quality below trimq.',
        default='r', type=str)
    parser.add_argument('--Bbduk_trimq', '-BB_tq', help='Regions with average quality BELOW this will be trimmed.',
        default=20, type=int)
    parser.add_argument('--Bbduk_k', '-BB_k',
        help='K-mer length used for finding contaminants. Contaminants shorter than k will not be found. '
        'k must be at least 1.', default=23, type=int)
    parser.add_argument('--Bbduk_mink', '-BB_mk',
        help='Look for shorter k-mers at read tips down to this length, when k-trimming or masking.',
        default=11, type=int)
    parser.add_argument('--Bbduk_hdist', '-BB_hd',
        help='Maximum Hamming distance for ref k-mers (subs only). Memory use is proportional to '
        '(3*K)^hdist.', default=1, type=int)
    parser.add_argument('--Bbduk_ftm', '-BB_ftm',
        help='If positive, right-trim length to be equal to zero, modulo this number.',
        default=5, type=int)
    parser.add_argument('--Bbduk_chastityfilter', '-BB_cf',
        help='Remove reads with unexpected barcodes if barcodes is set.',
        default='f', type=str)
    parser.add_argument('--Bbduk_minlen', '-BB_ml',
        help='Reads shorter than this after trimming will be discarded. Pairs will be discarded if both '
        'are shorter.', default=50, type=int)

    # HaplotypeCaller
    parser.add_argument('--HaplotypeCaller_ploidy', '-HC_p',
        help="Ploidy (number of chromosomes) per sample. For pooled data, set to (Number of samples in "
        "each pool * Sample Ploidy).", default=1, type=int)
    parser.add_argument('--HaplotypeCaller_confidence', '-HC_c',
        help="The minimum phred-scaled confidence threshold at which variants should be called.",
        default=20, type=int)

    parser.add_argument('--BaseRecalibration', '-brec',
        help='Pipeline to include base recalibration.', default=0, type=int)


    parser.add_argument('--Cores', '-c',
        help='Max cores a single tool can use.', default=1, type=int)
    parser.add_argument(
        '--CreateYAML', '-y',
        help='Should the process create a .yaml file or use an existing one (1-yes, 0-no) (WARNING: Other settings given as arguments will be overwritten by entries in .yaml).',
        choices=['TRUE', 'FALSE'], type=str, default='TRUE')
    parser.add_argument('--Flag', '-f',
        help='Test the workflow, without running any processes (1-ON, 0-OFF).', type=int, default=0)
    parser.add_argument('--Jobs', '-j',
        help='Number of jobs to run in parallel.', type=int, default=1)

    return(parser)
