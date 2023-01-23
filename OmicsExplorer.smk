## A set of functions ##
import sys
def message(mes):
    sys.stderr.write("|--- " + mes + "\n")

## The list of samples to be processed ##
SAMPLES, = glob_wildcards("{sample}_1.fq.gz")
NB_SAMPLES = len(SAMPLES)
THREADS = 10
rule qc_filtering:
    input:
        forward="{sample}_1.fq.gz",
        reverse="{sample}_2.fq.gz"
    output:
        forward_trim="{sample}_trim_1.fq.gz",
        reverse_trim="{sample}_trim_2.fq.gz",
        trim_forward_unpaired="{sample}_unpaired_1.fq.gz",
        trim_reverse_unpaired="{sample}_unpaired_2.fq.gz",
        forward_trim_no_dups="{sample}_trim_no_dups_1.fq.gz",
        reverse_trim_no_dups="{sample}_trim_no_dups_2.fq.gz"
     shell:
        """
        trimmomatic PE -threads "{THREADS}" \
        -phred33 {input.forward} \
        {input.reverse} \
        {output.forward_trim} {output.trim_forward_unpaired} \
        {output.reverse_trim} {output.trim_reverse_unpaired} \
        LEADING:20 \
        TRAILING:20 \
        MINLEN:50
        # remove duplicates
        seqkit rmdup {output.forward_trim} -s -o {output.forward_trim_no_dups} -j "{THREADS}"
        seqkit rmdup {output.reverse_trim} -s -o {output.reverse_trim_no_dups} -j "{THREADS}"
        rm {output.forward_trim}
        rm {output.reverse_trim}
        """

rule host_removal:
    input:
        forward="{sample}_trim_no_dups_1.fq.gz",
        reverse="{sample}_trim_no_dups_2.fq.gz"
    output:
        forward_noHost="{sample}_noHost_1.fq.gz",
        reverse_noHost="{sample}_noHost_2.fq.gz",
        Host="{sample}_noHost.bam"
    shell:
       """
       """    
