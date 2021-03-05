import os
import json
from plumbum import local as Cmd
from plumbum import TEE
from functions import enable_logging, interpret_result, write_result_to_debug


class QtlTolls:
    """Calls QTL tools to run in docker container"""

    def __init__(self):
        """Start docker container end define instance variables"""
        self.python_folder = os.getcwd()
        self.ori_samples = []
        self.gatk = '../../gatk/gatk.jar'
        self.picard = '/usr/picard/picard.jar'

        os.chdir('..')
        self.home = os.getcwd()

        self.logger = enable_logging(
            log_name='process_logger', log_file='log/sample_processing.log')
        self.st_logger = enable_logging(
            log_name='standard_output_logger', log_file='log/standard_output.log')

        # Paths, files and parameters needed for successful pipeline run.
        # Paths on the host.
        self.local_input = self.home + '/input/sample_data'
        self.local_adapters = self.home + '/input/adapters'
        self.local_ref = self.home + '/input/references'
        self.local_output = self.home + '/output'

        self.logger.info(f"Process initialized.")

    def populate_samples(self, marker_position, single_reads="FALSE"):
        """Obtain samples"""

        # Collate samples.
        base = self.local_input
        raw_files = os.listdir(base)

        # split the name for further analysis
        sample_names = []
        for sample in raw_files:
            name = sample.split(".")[0]
            sub = [name.split("_"), sample]
            sample_names.append(sub)

        # pair the data
        ori_samples = {}
        sample_names.sort()
        if single_reads == "TRUE":
            for data in sample_names:
                ori_samples.update(
                    {"_".join(data[0][:marker_position]): data[1]})
        else:
            r1 = 'empty'
            r2 = r1
            for data in sample_names:
                if 'R1' in data[0]:
                    r1 = data[1]
                if 'R2' in data[0]:
                    r2 = data[1]
                if r1 != 'empty' and r2 != 'empty':
                    ori_samples.update(
                        {"_".join(data[0][:marker_position]): {"R1": r1, "R2": r2}})
                    r1 = 'empty'
                    r2 = r1

        self.ori_samples = ori_samples
        os.chdir(self.home + '/log')

        pickle_file = "samples.pickle"
        with open(pickle_file, "w") as file:
            json.dump(ori_samples, file)

        self.logger.info(f"Populated samples from inputs: {raw_files}.")

    def make_references(self, fasta_ref_file, ref_vcf):
        """Crete bwa index, index referencing and dictionary of ref. sequence."""

        ref_name = fasta_ref_file.split('.')[:-1]
        if len(ref_name) > 1:
            ref_name = '.'.join(ref_name)
        else:
            ref_name = ref_name[0]

        fasta_ref_file_path = f"../input/references/{fasta_ref_file}"
        vcf_ref_file_path = f"../input/references/{ref_vcf}"
        ref_name_path = f"../input/references/{ref_name}"

        # Create bwa index
        result = Cmd["bwa"]["index", fasta_ref_file_path] & TEE(retcode=None)

        interpret_result(
            log=self.logger,
            so_logger=self.st_logger,
            report=result,
            logger_mes=f'[BWA index] index created.',
            logger_error_mes=f'[BWA index] For some reason the creation of index was not successful.',
            runtime_error_mes=f'bwa index failed ({fasta_ref_file}).'
        )

        # Make index referencing
        result = Cmd["samtools"]["faidx",
                                 fasta_ref_file_path] & TEE(retcode=None)

        interpret_result(
            log=self.logger,
            so_logger=self.st_logger,
            report=result,
            logger_mes=f'[Samtools faidx] indexing referencing done.',
            logger_error_mes=f'[Samtools faidx] For some reason indexing referencing was not successful.',
            runtime_error_mes=f'Samtools faidx failed ({fasta_ref_file}).'
        )

        # Make dictionary
        if not os.path.isfile(ref_name_path + '.dict'):

            args = [self.picard, 'CreateSequenceDictionary',
                    f'REFERENCE={fasta_ref_file_path}']

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[Picard CreateSequenceDictionary] Sequence dictionary created.',
                logger_error_mes=f'[Picard CreateSequenceDictionary] For some reason creation '
                                 f'of dictionary was not successful.',
                runtime_error_mes=f'Picard CreateSequenceDictionary failed ({fasta_ref_file}).'
            )

        # VCF index creation
        if not os.path.isfile(ref_name_path + '.tbi'):

            args = [self.gatk, 'IndexFeatureFile', '-I', vcf_ref_file_path]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK] Index creation with IndexFeatureFile for {ref_vcf} was successful.',
                logger_error_mes=f'[GATK] For some reason index creation with IndexFeatureFile for {ref_vcf} was not successful.',
                runtime_error_mes=f'IndexFeatureFile Index creation failed ({ref_vcf}).'
            )

    def fastqc(self, status, sample, in1, in2):
        """Create a report of fasta file quality."""
        os.chdir(self.local_input)

        result = Cmd['fastqc'][in1, in2, '-o',
                               f'{self.local_output}/fastqc/{status}/'] & TEE(retcode=None)

        interpret_result(
            log=self.logger,
            so_logger=self.st_logger,
            report=result,
            logger_mes=f'[Fastqc] Sample {sample} analysed successfully.',
            logger_error_mes=f'[FastQC] For some reason the analysis of {sample} was not successful.',
            runtime_error_mes=f'FastQC failed ({sample}).'
        )

    def fastqc_single(self, status, sample, in1):
        """Create a report of fasta file quality."""
        os.chdir(self.local_input)

        result = Cmd['fastqc'][in1, '-o',
                               f'{self.local_output}/fastqc/{status}/'] & TEE(retcode=None)

        interpret_result(
            log=self.logger,
            so_logger=self.st_logger,
            report=result,
            logger_mes=f'[Fastqc] Sample {sample} analysed successfully.',
            logger_error_mes=f'[FastQC] For some reason the analysis of {sample} was not successful.',
            runtime_error_mes=f'FastQC failed ({sample}).'
        )

    def bbduk(
            self, sample, r1_name, r2_name, r1, r2, exe, n_cores, ktrim, qtrim, trimq, k, mink, hdist, ftm,
            chastityfilter, minlen, adapters
    ):
        """Trimming with BBduk."""
        # set parameters
        trimmed1 = f'{self.local_output}/trimmed/BBduk_{r1_name}.fastq'
        trimmed2 = f'{self.local_output}/trimmed/BBduk_{r2_name}.fastq'

        if exe == 1:
            os.chdir(self.home)

            args = [
                f'in={r1}',
                f'in2={r2}',
                f'out={trimmed1}',
                f'out2={trimmed2}',
                f'ref={self.local_adapters}/{adapters}',
                f'ktrim={ktrim}',
                f'qtrim={qtrim}',
                f'trimq={trimq}',
                f'overwrite=true',
                f'k={k}',
                f'mink={mink}',
                f'hdist={hdist}',
                f'tpe',
                f'tbo',
                f'ftm={ftm}',
                f'chastityfilter={chastityfilter}',
                f'minlen={minlen}',
                f'threads={n_cores}'
            ]

            # run BBduk
            result = Cmd['bbduk.sh'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[BBduk] Sample {sample} trimmed successfully.',
                logger_error_mes=f'[BBduk] For some reason the trimming of {sample} was not successful.',
                runtime_error_mes=f'BBduk failed ({sample}).'
            )

        return [trimmed1, trimmed2]

    def bbduk_single(
            self, sample, r1_name, r1, exe, n_cores, ktrim, qtrim, trimq, k, mink, hdist, ftm, chastityfilter, minlen,
            adapters
    ):
        """Trimming with BBduk single reads."""
        trimmed = f'{self.local_output}/trimmed/BBduk_{r1_name}.fastq'

        if exe == 1:
            os.chdir(self.home)

            args = [
                f'in={r1}',
                f'out={trimmed}',
                f'ref={self.local_adapters}/{adapters}',
                f'ktrim={ktrim}',
                f'qtrim={qtrim}',
                f'trimq={trimq}',
                f'overwrite=true',
                f'k={k}',
                f'mink={mink}',
                f'hdist={hdist}',
                f'tpe',
                f'tbo',
                f'ftm={ftm}',
                f'chastityfilter={chastityfilter}',
                f'minlen={minlen}',
                f'threads={n_cores}'
            ]

            # run BBduk
            result = Cmd['bbduk.sh'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[BBduk] Sample {sample} trimmed successfully.',
                logger_error_mes=f'[BBduk] For some reason the trimming of {sample} was not successful.',
                runtime_error_mes=f'BBduk failed ({sample}).'
            )

        return trimmed

    def bwa_single(self, sample, reference, in1, exe, core):
        """Aligning with BWA."""
        out_bam = f'{self.local_output}/aligned/{sample}.bam'

        if exe == 1:
            os.chdir(self.home)

            bwa = Cmd['bwa']
            samtools = Cmd['samtools']
            args = [
                "mem",
                '-t', core,
                '-M', reference,
                in1
            ]

            # run BWA
            result = (bwa[args] | samtools['fixmate', '-m', '-', '-']
                      | samtools['sort', '-o', out_bam]) & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[BWA] Sample {sample} aligned successfully.',
                logger_error_mes=f'[BWA] For some reason the alignment of {sample} was not successful.',
                runtime_error_mes=f'BWA failed ({sample}).'
            )

        return out_bam

    def bwa(self, sample, reference, in1, in2, exe, core):
        """Aligning with BWA."""
        out_bam = f'{self.local_output}/aligned/{sample}.bam'

        if exe == 1:
            os.chdir(self.home)
            out_bam = f'{self.local_output}/aligned/{sample}.bam'

            bwa = Cmd['bwa']
            samtools = Cmd['samtools']
            args = [
                "mem",
                '-t', core,
                '-M', reference,
                in1,
                in2
            ]

            # run BWA
            result = (bwa[args] | samtools['fixmate', '-m', '-', '-']
                      | samtools['sort', '-o', out_bam]) & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[BWA] Sample {sample} aligned successfully.',
                logger_error_mes=f'[BWA] For some reason the alignment of {sample} was not successful.',
                runtime_error_mes=f'BWA failed ({sample}).'
            )

        return out_bam

    def samtools_index(self, sample, in1, exe):
        """Create index with samtools."""

        if exe == 1:
            os.chdir(self.home)
            samtools = Cmd['samtools']

            result = samtools['index', in1] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[Samtools index] Sample {sample} indexing successfully.',
                logger_error_mes=f'[Samtools index] For some reasonthe indexing of {sample} was not successful.',
                runtime_error_mes=f'Samtools index failed ({sample}).'
            )

    def picard_rg(self, sample, in1, ref_organism, exe):
        """Add or replace read groups with Picard."""
        out = f'{self.local_output}/GATK/{sample}.RG.bam'

        if exe == 1:
            os.chdir(self.home)

            args = [
                self.picard,
                'AddOrReplaceReadGroups',
                f'INPUT={in1}',
                f'OUTPUT={out}',
                f'RGSM={sample}',
                f'RGPU=none',
                f'RGLB={ref_organism}',
                f'RGPL=ILLUMINA'
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[RG] Sample {sample} RG was successfully.',
                logger_error_mes=f'[RG] For some reason the RG of {sample} was not successful.',
                runtime_error_mes=f'RG failed ({sample}).'
            )

        return out

    def picard_md(self, sample, in1, exe):
        """Marking duplicates with Picard."""
        out = f'{self.local_output}/GATK/{sample}.Sorted.dedup.bam'

        if exe == 1:
            os.chdir(self.home)
            out_duplicated_metric = f'{self.local_output}/GATK/{sample}.sorted.dedup.metrics.txt'

            args = [
                self.picard,
                'MarkDuplicates',
                f'INPUT={in1}',
                f'OUTPUT={out}',
                f'METRICS_FILE={out_duplicated_metric}'
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[MD] Sample {sample} Marking duplicates was successfully.',
                logger_error_mes=f'[MD] For some reason the Marking duplicates of {sample} was not successful.',
                runtime_error_mes=f'Marking duplicates failed ({sample}).'
            )

        return out

    def gatk_BaseRecalibrator(self, sample, bam, ref_fasta, exe, ref_vcf):
        """Builds a model and then aplys it to get new quality scores"""
        bqsr_recal_table = f"{sample}_recal_data.table"
        out = f"{sample}.bqsrCal.bam"

        if exe == 1:
            os.chdir(self.home)

            args = [
                self.gatk,
                'BaseRecalibrator',
                '-R', ref_fasta,
                '-I', bam,
                '--use-original-qualities',
                '-known-sites', ref_vcf,
                '-O', bqsr_recal_table
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK] Sample {sample} Base model calibration was successful.',
                logger_error_mes=f'[GATK] For some reason base model calibration for {sample} was not successful.',
                runtime_error_mes=f'Base model calibration failed ({sample}).'
            )

            # Run ApplyBQSR
            args = [
                self.gatk,
                'ApplyBQSR',
                '--add-output-sam-program-record',
                '-R', ref_fasta,
                '-I', bam,
                '--use-original-qualities',
                '--bqsr-recal-file', bqsr_recal_table,
                '-O', out
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK] Sample {sample} quality score correction was successful.',
                logger_error_mes=f'[GATK] For some quality score correction of {sample} was not successful.',
                runtime_error_mes=f'Quality score correction failed ({sample}).'
            )

        return out

    def gatk_haplotype_caller(self, sample, in1, reference, exe, ploidy, confidence):
        """Call germline SNPs and indels via local re-assembly of haplotypes with GATK."""
        out = f'{self.local_output}/GATK/VCFs/{sample}-raw_variants.g.vcf'
        out_named = f'{self.local_output}/GATK/VCFs/{sample}-named_variants.g.vcf'

        if exe == 1:
            os.chdir(self.home)

            args = [
                self.gatk,
                'HaplotypeCaller',
                '-R', reference,
                '-I', in1,
                '-O', out,
                '-ploidy', ploidy,
                '-ERC', 'GVCF',
                '-stand-call-conf', confidence
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK HaplotypeCaller] Sample {sample} Calling germline SNPs and indels was successful.',
                logger_error_mes=f'[GATK HaplotypeCaller] For some reason Calling germline SNPs and indels of {sample} '
                                 f'was not successful.',
                runtime_error_mes=f'GATK HaplotypeCaller failed ({sample}).'
            )

            args = [
                self.picard,
                'RenameSampleInVcf',
                f'INPUT={out}',
                f'OUTPUT={out_named}',
                f'NEW_SAMPLE_NAME={sample}'
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[PICARD RenameSampleInVcf] Sample {sample} .gvcf sample naming was successful.',
                logger_error_mes=f'[PICARD RenameSampleInVcf] For some reason .gvcf sample naming of {sample} '
                                 f'was not successful.',
                runtime_error_mes=f'PICARD RenameSampleInVcf failed ({sample}).'
            )

            args = [
                self.gatk,
                'ValidateVariants',
                '--validate-GVCF',
                '-R', reference,
                '-V', out
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK ValidateVariants] Sample {sample} validation was successful.',
                logger_error_mes=f'[GATK ValidateVariants] For some reason validation of {sample} '
                                 f'was not successful.',
                runtime_error_mes=f'GATK ValidateVariants failed ({sample}).'
            )

        return out_named

    def gatk_merge_vcfs(self, exe, reference, sample):
        """Gather all created VCFs and combine them."""
        out = f"{self.local_output}/GATK/VCFs/{sample}-genotyped_variants.vcf.gz"
        out_merged = f"{self.local_output}/GATK/VCFs/{sample}-merged_variants.g.vcf.gz"

        if exe == 1:
            os.chdir(self.home)
            relevant_path = "output/GATK/VCFs/"
            included_extensions = ['-named_variants.g.vcf']
            file_names = [fn for fn in os.listdir(relevant_path)
                          if any(fn.endswith(ext) for ext in included_extensions)]

            input_variant_files_list = []
            variants = []
            for gvcf in file_names:
                sam = gvcf.split("-")[0]
                if sam in self.ori_samples:
                    input_variant_files_list.append(gvcf)
                    variants.append('-V')
                    variants.append("output/GATK/VCFs/" + gvcf)

            args = [
                self.gatk,
                'CombineGVCFs',
                variants,
                '-R', reference,
                '-O', out_merged
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK CombineGVCFs] combining g.VCFs was successful.',
                logger_error_mes=f'[GATK CombineGVCFs] For some reason the combining of g.VCFs '
                                 f'was not successful.',
                runtime_error_mes=f'GATK CombineGVCFs failed.'
            )

            args = [
                self.gatk,
                'GenotypeGVCFs',
                '-V', out_merged,
                '-R', reference,
                '-O', out
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK GenotypeGVCFs] Genotyping was successful.',
                logger_error_mes=f'[GATK GenotypeGVCFs] For some reason genotyping '
                                 f'was not successful.',
                runtime_error_mes=f'GATK GenotypeGVCFs failed.'
            )

        return out

    def gatk_variant_selection(self, sample, in1, out, reference, parameters, exe):
        """Select a subset of variants from a VCF file GATK."""

        if exe == 1:
            os.chdir(self.home)

            args = [
                self.gatk,
                'SelectVariants',
                '-R', reference,
                '-V', in1,
                '-O', out,
                '-select-type', parameters
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK SelectVariants] Sample {sample} Selecting a subset of variants was successful.',
                logger_error_mes=f'[GATK SelectVariants] For some reason Selecting a subset of variants of {sample} '
                                 f'was not successful.',
                runtime_error_mes=f'GATK SelectVariants failed ({sample}).'
            )

        return out

    def gatk_varints_to_table(self, in1, sample, exe):
        """Transforms a .vcf file into a table"""
        out = f"{self.local_output}/GATK/tables/{sample}-raw.snps.table"

        if exe == 1:
            os.chdir(self.home)

            args = [
                self.gatk,
                'VariantsToTable',
                '-V', in1,
                '-F', 'CHROM',
                '-F', 'POS',
                '-F', 'REF',
                '-F', 'ALT',
                '-GF', 'DP',
                '-GF', 'AD',
                '-GF', 'GQ',
                '-GF', 'PL',
                '-O', out,
            ]

            result = Cmd['java']['-jar'][args] & TEE(retcode=None)

            interpret_result(
                log=self.logger,
                so_logger=self.st_logger,
                report=result,
                logger_mes=f'[GATK VariantsToTable] Sample {sample} table creation was successful.',
                logger_error_mes=f'[GATK VariantsToTable] For some reason the table creation of {sample} '
                                 f'was not successful.',
                runtime_error_mes=f'GATK VariantsToTable failed ({sample}).'
            )

        return out

    def done(self):
        """Report that the pipeline has finished."""
        self.logger.info("Finished!")
