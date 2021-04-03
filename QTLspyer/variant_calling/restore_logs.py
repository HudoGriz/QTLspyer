#!/usr/bin/env python3
import os


def main():
    os.chdir('..')

    with open('log/sample_processing.log', 'w') as f:
        f.write(
            f"Hello :)\n\n"
            f"Taking the following steps is advised:\n"
            f"1.  Provide the input data.\n"
            f"2.  (Optional) Only run FastQC to obtain quality reports.\n"
            f"3.  Run the Germline short variant discovery pipeline.\n"
            f"4.  Import the data and filter it.\n"
            f"5.  Analyse the filtered data.\n"
            f"6.  Observe the results and repeat the filtering with different settings if needed.\n"
            f"7.  Save the plots and tables.\n\n"
            f"Before you start please make sure that all the input files required\n"
            f"are provided for your target organism and are appropriately named.\n"
            f"Reference data for Saccharomyces cerevisiae is already provided.\n\n"
            f"  input\n"
            f"  |-- adapters                    # Expects adapters for sequence trimming (.fasta)\n"
            f"  |-- annotation                  # Expects genome annotation (.gtf)\n"
            f"  |-- references                  # Expects genome references (.fasta & .vcf)\n"
            f"  |-- sample_data                 # Expects sample read sequences (.fastq)\n\n"
            f"When the right inputs have been provided, select fitting parameters\n"
            f"and press *start process*. The process can be stopped at any time\n"
            f"but the data from the current tool will most likely be corrupt.\n"
            f"Re-running from the last successfully completed step is recommended\n\n"
            f"For in depth information about each step please refer to the *Info* tab.\n\n"
            f"Pro tip: you can run this process gradually by selecting which tools to run.\n"
        )

    with open('log/standard_output.log', 'w') as f:
        f.write(
            "Let's get started!\n"
        )

    with open('log/samples.pickle', 'w') as f:
        f.write("")


if __name__ == '__main__':
    main()
