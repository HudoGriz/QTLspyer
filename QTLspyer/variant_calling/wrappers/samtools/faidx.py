from plumbum import local as Cmd
from plumbum import TEE
from scripts.functions import interpret_result


threads = "" if snakemake.threads <= 1 else " -@ {} ".format(snakemake.threads - 1)

result = Cmd["samtools"]["faidx", f"-@ {threads}", snakemake.input] & TEE(retcode=None)

interpret_result(
    log=snakemake.params.loger,
    so_logger=snakemake.params.st_logger,
    report=result,
    logger_mes=f'[Samtools faidx] indexing referencing done.',
    logger_error_mes=f'[Samtools faidx] For some reason indexing referencing was not successful.',
    runtime_error_mes=f'Samtools faidx failed ({snakemake.input}).'
)
