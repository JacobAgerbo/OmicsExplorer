#!/bin/bash
#####################################################################
## Version 0.0.1                           												 ##
## Written by Jacob Agerbo Rasmussen, jacob.rasmussen@bio.ku.dk 	 ##
#####################################################################

### Set PBS options ###
SBATCH_PARAMS=('--nodes=1' '--time=2:00:00:00' '--mem=10G')
JobName="01_Snakemake" ## as short as possible < 8 letters
EmailNotf="-m  n" ## replace your email address here
Adapter1="AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA" # forward adapter for trimmomatic
Adapter2="AAGTCGGATCGTAGCCATGTCGTTC" # reverse adapter for trimmomatic
RefG="/projects/mjolnir1/people/bfg522/02_FlyProject_Tom/REF/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna" # Reference for host-removal
### Set snakemake options ###
NumJobsNode=4
WorkDir=`pwd -P`
SnakeMakeFile=`echo ${WorkDir}/Workflows/01_Preprocessing.smk`
ConfigFile=`echo ${WorkDir}/Workflows/01_config.yaml`
RawDataDir=`echo ${WorkDir}/00_RawData`
DesDir=`echo ${WorkDir}/02_HostRmval/00_QC/`
if [ ! -f ${SnakeMakeFile} ]; then
	echo "OmicsExplorer preprocessing snakemake file is found in current working directory!"
	echo "Go to the correct working directory with ${SnakeMakeFile}"
	echo "No jobs where submitted to PBS queue."
	exit 0
fi
if [ ! -d ${RawDataDir} ]; then
        echo "00_RawData directory is not found in current working directory!"
        echo "No jobs where submitted to PBS queue."
        exit 0
fi

### Set parameters for the pipeline

if [ ! -f ${RefG} ]; then
        echo "Reference Genome is not found!"
        echo "No jobs where submitted to PBS queue."
        exit 0
fi
echo "adapter1: $Adapter1" > $ConfigFile
echo "adapter2: $Adapter2" >> $ConfigFile
echo "maxns: $MaxNs" >> $ConfigFile
echo "minquality: $MinQuality" >> $ConfigFile
echo "minlength: $MinLength" >> $ConfigFile
echo "refgenomehost: $RefG" >> $ConfigFile

###
NumSamples=`ls -1 -d ${RawDataDir}/*_1.fq.gz | grep -vc "^\s*$"`
if [ $NumSamples == 0 ]; then
	echo "No FastQ files are found in 00_RawData directory!"
	echo "Please make sure of your path ${RawDataDir}."
	echo "Furthermore, make sure your samples have the postfix '.fq.gz' inside ${RawDataDir}"
	echo "No jobs where submitted to PBS queue."
	exit 0
fi
NumNodes=`echo "(${NumSamples}-1)/${NumJobsNode}+1" | bc`

### Submit snakemake jobs to PBS queue
#module purge
#module load shared tools
module load anaconda3/4.0.0
conda activate OmixExplorer
for ((njob=1;njob<=${NumNodes};njob++))
do
  StartLine=`echo "(${njob}-1)*${NumJobsNode}+1" | bc`
  EndLine=`echo "${njob}*${NumJobsNode}" | bc`
  OutFiles=`ls -1 -d ${RawDataDir}/*_1.fq.gz | rev | cut -d '_' -f 2- | cut -d '/' -f 1 | rev | sed -n ${StartLine},${EndLine}p | sed "s|^|${DesDir}\/|g" | sed 's|$|_mapsum.csv|g' | paste -s -d " " -`
  CMD_FOR_SUB=$(cat <<EOF
  SLURM_CPUS_ON_NODE=\${SLURM_CPUS_ON_NODE:-8}
  SLURM_CPUS_PER_TASK=\${SLURM_CPUS_PER_TASK:-\$SLURM_CPUS_ON_NODE}
  export OMP_NUM_THREADS=\$SLURM_CPUS_PER_TASK

  snakemake -s ${SnakeMakeFile} --configfile ${ConfigFile} --cores $(echo ${SysRes} | cut -d ',' -f 1 | cut -d '=' -f 3) -r -p ${OutFiles}
EOF
)
sbatch ${SBATCH_PARAMS[@]} --job-name=${JobName}_${njob} -o ${JobName}_${njob}.log --wrap "$CMD_FOR_SUB"
done
