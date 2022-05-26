rule picard_dict:
    input:
        "genome.fasta",
    output:
        "genome.dict",
    log:
        "logs/picard/create_dict.log",
    params:
        extra = "",  # optional: extra arguments for picard.
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
        picard = picard_PATH,
    resources:
        mem_mb = 1024,
    wrapper:
        "wrappers/picard/dict.py"