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
SAMPLES, = glob_wildcards("${RawDataDir}/{sample}_1.fq.gz")
NB_SAMPLES = len(SAMPLES)
THREADS = 8

###
rule qc_filtering:
    input:
        forward="${RawDataDir}/{sample}_1.fq.gz",
        reverse="${RawDataDir}/{sample}_2.fq.gz"
    output:
        forward_trim="{WorkDir}/01_QualityFiltered/{sample}_trim_1.fq.gz",
        reverse_trim="{WorkDir}/01_QualityFiltered/{sample}_trim_2.fq.gz",
        trim_forward_unpaired="{WorkDir}/01_QualityFiltered/{sample}_unpaired_1.fq.gz",
        trim_reverse_unpaired="{WorkDir}/01_QualityFiltered/{sample}_unpaired_2.fq.gz",
        forward_trim_no_dups="{WorkDir}/01_QualityFiltered/{sample}_trim_no_dups_1.fq.gz",
        reverse_trim_no_dups="{WorkDir}/01_QualityFiltered/{sample}_trim_no_dups_2.fq.gz",
        forward_qc_filtered="{WorkDir}/01_QualityFiltered/{sample}_qc_filtered_1.fq.gz",
        reverse_qc_filtered="{WorkDir}/01_QualityFiltered/{sample}_qc_filtered_2.fq.gz"
     shell:
        """
        # remove adaptors and low quality reads
        trimmomatic PE -threads {THREADS} \
        -phred33 {input.forward} \
        {input.reverse} \
        {output.forward_trim} {output.trim_forward_unpaired} \
        {output.reverse_trim} {output.trim_reverse_unpaired} \
        LEADING:20 \
        TRAILING:20 \
        MINLEN:50
        rm {output.trim_forward_unpaired}
        rm {output.trim_reverse_unpaired}
        # remove duplicates
        seqkit rmdup {output.forward_trim} -s -o {output.forward_trim_no_dups} -j {THREADS}
        seqkit rmdup {output.reverse_trim} -s -o {output.reverse_trim_no_dups} -j {THREADS}
        rm {output.forward_trim}
        rm {output.reverse_trim}
        # remove singletons
        fastq_pair {output.forward_trim_no_dups} {output.reverse_trim_no_dups}
        mv left.fastq.paired.fq.gz {output.forward_qc_filtered}
        mv right.fastq.paired.fq.gz {output.reverse_qc_filtered}
        rm *single*
        """
###
rule host_removal:
    input:
        forward="{WorkDir}/01_QualityFiltered/{sample}_qc_filtered_1.fq.gz",
        reverse="{WorkDir}/01_QualityFiltered/{sample}_qc_filtered_2.fq.gz"
    output:
        bam_all="{WorkDir}/02_HostRmval/{sample}_all.bam",
        forward_noHost="{WorkDir}/02_HostRmval/{sample}_noHost_1.fq.gz",
        reverse_noHost="{WorkDir}/02_HostRmval/{sample}_noHost_2.fq.gz",
        host="{WorkDir}/02_HostRmval/{sample}_map2host.bam"
    params:
		refgnm=expand("{refgnm}", refgnm=config['refgenomehost'])
	THREADS: 8
	shell:
		"""
		bwa mem -M -t {THREADS} {params.refgnm} {input.read1} {input.read2} | samtools sort --threads {threads} -o {output.bam_all}
		samtools view -b -F12 -@ {THREADS} {output.bam_all} > {output.host}
		samtools view -b -f12 -@ {THREADS} {output.bam_all} | samtools fastq --threads {THREADS} -N -1 {output.forward_noHost} -2 {output.reverse_noHost}
		"""
###
rule make_bam_qc_report:
	input:
		bam_all="{WorkDir}/02_HostRmval/{sample}_all.bam"
	output:
		bamqc_all="{WorkDir}/02_HostRmval/00_QC/{sample}_all.tar",
		gerslt_all="{WorkDir}/02_HostRmval/00_QC/{sample}_mapsum.csv"
	params:
		prefix="{WorkDir}/02_HostRmval/00_QC/{sample}"
	shell:
		"""
		qualimap bamqc -bam {input.bam_all} -outdir {params.prefix}_all -outformat html --java-mem-size=16G
		head -n 73 {params.prefix}_all/genome_results.txt | sed '/^[[:space:]]*$/d' | sed 's/>//g' | sed 's/^[[:space:]]*//' | grep -v 'BamQC' | sed 's/ = /;/g' | grep -v 'bam file' | sed -e "s/Input/Input;{wildcards.sample}/g" > {output.gerslt_all}
		rm {input.bam_all}
		"""
