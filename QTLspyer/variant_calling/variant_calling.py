#!/usr/bin/env python3

import os
import yaml

from plumbum import local as Cmd
from plumbum import TEE
from scripts.argument_parser import parse
from scripts.functions import enable_logging, interpret_result, write_result_to_debug


parsed = parse()
args = parsed.parse_args()

path = '/QTLspyer/output'
if not os.path.exists(path):
    os.makedirs(path)

if args.CreateYAML == 1:
    with open(path + '/config.yaml', 'w') as outfile:
        yaml.dump(str(args), outfile, default_flow_style=False)


os.chdir('/QTLspyer/variant_calling')

snakemake = Cmd['snakemake']

if args.Flag == 1:
    print("testing workflow")

    # (snakemake['--dag'] | Cmd['dot']['-Tsvg', '-o', '/app/data/output_folder/dag.svg']) & TEE(retcode=None)

    # command_args = ['--use-conda', '-n', '--reason', f'-j {args.Jobs}', '-p']
# else:
    # command_args = ['--use-conda', f'-j {args.Jobs}', '-p']

# snakemake[command_args] & TEE(retcode=None)

