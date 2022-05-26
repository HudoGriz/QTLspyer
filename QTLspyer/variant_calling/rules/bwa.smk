rule bwa_index:
    input:
        "{genome}.fasta",
    output:
        idx = multiext("{genome}", ".amb", ".ann", ".bwt", ".pac", ".sa"),
    params:
        algorithm = "bwtsw",
        logger = logger,
        st_logger = st_logger,
    wrapper:
        "wrappers/bwa/index.py"


