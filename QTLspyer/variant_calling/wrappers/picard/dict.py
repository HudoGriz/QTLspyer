from plumbum import local as Cmd
from plumbum import TEE
from scripts.functions import interpret_result
from scripts.utils.java import get_java_opts


extra = snakemake.params.get("extra", "")
java_opts = get_java_opts(snakemake)
args = [snakemake.params.picard, 'CreateSequenceDictionary', f'REFERENCE={snakemake.input}']

result = Cmd['java'][f'-jar {java_opts}'][args] & TEE(retcode=None)

interpret_result(
    log=snakemake.params.loger,
    so_logger=snakemake.params.st_loger,
    report=result,
    logger_mes=f'[Picard CreateSequenceDictionary] Sequence dictionary created.',
    logger_error_mes=f'[Picard CreateSequenceDictionary] For some reason creation '
                        f'of dictionary was not successful.',
    runtime_error_mes=f'Picard CreateSequenceDictionary failed ({fasta_ref_file}).'
)
