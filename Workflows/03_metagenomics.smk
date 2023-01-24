#####################################################################
## Version 0.0.1                           						   ##
## Written by Jacob Agerbo Rasmussen, jacob.rasmussen@bio.ku.dk    ##
#####################################################################
## Preprocessing Snakemake prior assembly
## A set of functions ##
import sys
def message(mes):
    sys.stderr.write("|--- " + mes + "\n")


    params:
        config=expand("{config}", Assembly_type=config['config'])

    shell:
        """
        anvi-run-workflow -w metagenomics \
                          -c {params.config} \
                          --save-workflow-graph
        """
