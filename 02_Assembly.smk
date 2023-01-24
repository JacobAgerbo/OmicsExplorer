#####################################################################
## Version 0.0.1                           						   ##
## Written by Jacob Agerbo Rasmussen, jacob.rasmussen@bio.ku.dk    ##
#####################################################################
## Preprocessing Snakemake prior assembly
## A set of functions ##
import sys
def message(mes):
    sys.stderr.write("|--- " + mes + "\n")

## The list of samples to be processed ##
SAMPLES, = glob_wildcards("${WorkDir}/{sample}_1.fq.gz")
NB_SAMPLES = len(SAMPLES)
THREADS = 8
###
rule MG_assembly
    input:
    output:
    params:
    THREADS: 8
    shell:
