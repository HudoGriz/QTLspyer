rule samtools_faidx:
    input:
        "mapped/{sample}.sorted.bam",
    output:
        "mapped/{sample}.sorted.bam.bai",
    params:
        extra="",
        logger = logger,
        st_logger = st_logger,
    threads: 1,
    wrapper:
        "wrappers/samtools/faidx.py"