#!/bin/bash
#####################################################################
## Version 0.0.1                           												 ##
## Written by Jacob Agerbo Rasmussen, jacob.rasmussen@bio.ku.dk 	 ##
#####################################################################

### Set PBS options ###
SBATCH_PARAMS=('--nodes=1' '--time=2:00:00:00' '--mem=256G')
JobName="02_Snakemake" ## as short as possible < 8 letters
EmailNotf="-m  n" ## replace your email address here

### Set snakemake options ###
WorkDir=`pwd -P`
SnakeMakeFile=`echo ${WorkDir}/02_Assembly.smk`
ConfigFile=`echo ${WorkDir}/02_config.yaml`
RawDataDir=`echo ${WorkDir}/00_RawData`
DesDir=`echo ${WorkDir}/03_Assembly`

Assembler="megahit" #choose between "megahit" and "spades"
Assembly_type="single" # choose between "single" or "coassembly"
MINLENGTH=2000 # minimum length for contigs

if [ ! -f ${SnakeMakeFile} ]
	then
		echo "OmicsExplorer preprocessing snakemake file is found in current working directory!"
		echo "Go to the correct working directory with ${SnakeMakeFile}"
		echo "No jobs where submitted to PBS queue."
		exit 0
fi

no_RAW=`ls ${WorkDir}/00_RawData/*_1.fq.gz | wc -l`
no_Clean=`ls ${WorkDir}/02_HostRmval/*_noHost_1.fq.gz | wc -l`

if [ $no_RAW -ne $no_Clean ]
	then
    echo "OmicsExplorer could not find same number of"
		echo "samples between raw data repo and filtered repo"
    echo "Have you runned '01_Preprocessing.smk'?"
		exit 0
fi

if [ ${Assembly_type} != "single" ] && [ ${Assembly_type} != "coassembly" ]
	then
    echo "OmicsExplorer could not find a specified assembly type"
		echo "Please specify assembly type, either 'single' and 'coassembly'"
    echo "No jobs where submitted to PBS queue."
		exit 0
fi

if [ ${Assembler} != "megahit" ] && [ ${Assembler} != "spades" ]
	then
    echo "OmicsExplorer could not find a specified assembler"
		echo "Please specify assembler, either 'megahit' and 'spades'"
    echo "No jobs where submitted to PBS queue."
		exit 0
fi

if [ ${Assembly_type} = "coassembly" && [ ${Assembler} = "spades" ]
	then
    echo "OmicsExplorer will not make co-assemblies with SPAdes"
		echo "This would deplete all memory resources on the cluster"
		echo "Therefore, OmicsExplorer choose megahit for co-assmebly"
  	Assembler="megahit"
fi


if [ ${Assembly_type} = "single" ]
then
 NumJobsNode=8
elif [ ${Assembly_type} = "coassembly" ]
then
 NumJobsNode=1
else
 NumJobsNode=8
fi


### Set parameters for the pipeline
echo "Assembler: $Assembler" >> $ConfigFile
echo "Assembly_Type: $Assembly_type" >> $ConfigFile
echo "MINLENGTH: $MINLENGTH" >> $ConfigFile

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
