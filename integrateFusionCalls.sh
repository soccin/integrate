#!/bin/bash
#SBATCH --job-name=INTEGRATE
#SBATCH --time=3-00:00:00
#SBATCH --partition=test01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=144GB
#SBATCH --output=SLM/integrate_%j.out

# BSUB: -o LSF/ -n 12 -R "rusage[mem=12]" -R cmorsc1 -W 24:00

if [ -n "${SBATCH_SCRIPT_DIR}" ]; then
    SDIR="${SBATCH_SCRIPT_DIR}"
else
    SDIR=$(dirname "$(readlink -f "$0")")
fi

set -e

module load samtools

. $SDIR/../bin/getClusterName.sh

if [ "$CLUSTER" == "JUNO" ]; then
  # JUNO specific paths
  export PATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/opt/bin:$PATH
  DBPATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/db
elif [ "$CLUSTER" == "IRIS" ]; then
  # IRIS specific paths
  export PATH=/data1/core001/work/bic/socci/Pipelines/Integrate/opt/bin:$PATH
  DBPATH=/data1/core001/work/bic/socci/Pipelines/Integrate/db
else
  echo -e "\n   UNKNOWN CLUSTER" $CLUSTER "\n\n"
  exit 1
fi

. $DBPATH/bundle.human_b37

ARGC=$#


SID=$1
RNA_BAM=$2
DNA_TUMOR_BAM=$3

if [ $ARGC == "4" ]; then

    DNA_NORMAL_BAM=$(realpath $4)

else

    DNA_NORMAL_BAM=""

fi

usage () {
    echo -e "\n    usage: integrateFusionCalls.sh SID RNA_BAM DNA_TUMOR_BAM [DNA_NORMAL_BAM]"
    echo -e "\n       For LSF: bsub -o LSF/ -n 12 -R "rusage[mem=12]" -R cmorsc1 -W 24:00\n"
}

if [ ! -e "$RNA_BAM" ]; then
    usage
    echo -e "    RNA_BAM = ["${RNA_BAM}"] does not exists\n"
    exit
fi

if [ ! -e "$DNA_TUMOR_BAM" ]; then
    usage
    echo -e "    BAM = ["${DNA_TUMOR_BAM}"] does not exists\n"
    exit
fi

if [ "$DNA_NORMAL_BAM" != "" ]; then
    if [ ! -e "$DNA_NORMAL_BAM" ]; then
        usage
        echo -e "    BAM = ["${DNA_NORMAL_BAM}"] does not exists\n"
        exit
    fi
fi

if [ $ARGC == "4" ]; then

    ODIR=res/$SID/somatic

else

    ODIR=res/$SID/tOnly

fi

RNA_BAM=$(realpath $RNA_BAM)
DNA_TUMOR_BAM=$(realpath $DNA_TUMOR_BAM)

mkdir -vp $ODIR
cd $ODIR

Integrate fusion \
    -sample $SID \
    $GENOME_FASTA \
    $DBPATH/annotation/Homo_sapiens.GRCh37.75.B37_CLEAN.annote.txt \
    $INDEX_INTEGRATE \
    $RNA_BAM $RNA_BAM \
    $DNA_TUMOR_BAM \
    $DNA_NORMAL_BAM

