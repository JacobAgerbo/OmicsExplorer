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
SAMPLES, = glob_wildcards("{WorkDir}/02_HostRmval/{sample}_noHost_1.fq.gz")
NB_SAMPLES = len(SAMPLES)
THREADS = ${SLURM_CPUS_PER_TASK}
###
rule MG_assembly
    input:
        forward="{WorkDir}/02_HostRmval/{sample}_noHost_1.fq.gz"
        reverse="{WorkDir}/02_HostRmval/{sample}_noHost_2.fq.gz"
        all_fq="{WorkDir}/02_HostRmval/{sample}_noHost_*.fq.gz"
    output:
        co_assembly_contigs ="${WorkDir}/03_Assembly/Co_Assembly/
        single_assembly ="${WorkDir}/03_Assembly/{sample}/"
        filt_single_contigs ="${WorkDir}/03_Assembly/{sample}/{sample}_scaffolds.fasta"
    params:
        Assembler=expand("{Assembler}", Assembly_type=config['Assembler'])
        Assembly_type=expand("{Assembly_type}", Assembly_type=config['Assembly_type'])
        MINLENGTH=expand("{MINLENGTH}", Assembly_type=config['MINLENGTH'])
    shell:
        """
        mkdir ${WorkDir}/03_Assembly/
        if [ {params.Assembly_type} = "coassembly" ]
        	then
            echo "OmicsExplorer will merge all fastq files"
            echo "to make a co-assembly with MEGAHIT"
            FASTA=`ls {input.all_fq} | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`
        fi
        if [ {params.Assembler} = "megahit" ]
            then
        	megahit -r $FASTA --min-contig-len {params.MINLENGTH} -t $THREADS --presets meta-sensitive -o {output.co_assembly_contigs}
            elif [ {params.Assembler} = "spades" ]
            then
            spades.py --pe1-1 {input.forward} --pe1-2 {input.reverse} -o {output.single_assembly} -t $THREADS --only-assembler --meta
            seqkit seq {output.single_contigs}/scaffolds.fasta -m {params.MINLENGTH} -g > {output.filt_single_contigs}
        fi
        """
