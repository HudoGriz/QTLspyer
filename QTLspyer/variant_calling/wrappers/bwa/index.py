from plumbum import local as Cmd
from plumbum import TEE
from scripts.functions import interpret_result


result = Cmd["bwa"]["index", snakemake.input] & TEE(retcode=None)

interpret_result(
    log=snakemake.params.loger,
    so_logger=snakemake.params.st_logger,
    report=result,
    logger_mes=f'[BWA index] index created.',
    logger_error_mes=f'[BWA index] For some reason the creation of index was not successful.',
    runtime_error_mes=f'bwa index failed ({snakemake.input}).'
)
