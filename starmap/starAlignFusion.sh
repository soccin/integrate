#!/bin/bash
#SBATCH --job-name=starAlignFusion
#SBATCH --time=1-00:00:00
#SBATCH --partition=test01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=48GB
#SBATCH --output=SLM/starAlign_%j.out

# bsub -o LSF/ -J STARf -n 18 -W 359

#
# F*ck slurm, make sure you run this with
# the properly fixed ~/bin/sbatch that sets this
# variable
#
if [ -n "${SBATCH_SCRIPT_DIR}" ]; then
    SDIR="${SBATCH_SCRIPT_DIR}"
else
    SDIR=$(dirname "$(readlink -f "$0")")
fi

set -e

module load samtools

. $SDIR/../bin/getClusterName.sh

if [ "$CLUSTER" == "JUNO" ]; then
  export PATH=/opt/common/CentOS_7/star/STAR-2.7.0a/bin:$PATH
elif [ "$CLUSTER" == "IRIS" ]; then
  export PATH=/usersoftware/core001/common/RHEL_8/star/2.7.0a/bin:$PATH
else
  echo -e "\n   UNKNOWN CLUSTER" $CLUSTER "\n\n"
  exit 1
fi

BUNDLE_FILE="$SDIR/bundle.${CLUSTER}.human_b37"
if [ ! -f "$BUNDLE_FILE" ]; then
    echo -e "\n   ERROR: Bundle file $BUNDLE_FILE does not exist\n"
    exit 1
fi
source "$BUNDLE_FILE"


THREADS=16

if [ $# -ne 3 ]; then
    echo
    echo "Usage: $(basename $0) <SAMPLE_ID> <READ1_FILE> <READ2_FILE>"
    echo
    echo "  SAMPLE_ID   : Sample identifier for output directory naming"
    echo "  READ1_FILE  : Path to first paired-end FASTQ file (R1)"
    echo "  READ2_FILE  : Path to second paired-end FASTQ file (R2)"
    echo
    echo "Example:"
    echo "  $(basename $0) Sample01 reads/Sample01_R1.fastq.gz reads/Sample01_R2.fastq.gz"
    echo "SLURM:"
    echo "  sbatch $(basename $0) Sample01 reads/Sample01_R1.fastq.gz reads/Sample01_R2.fastq.gz"
    echo
    exit 1
fi

SID=$1
R1=$2
R2=$3

mkdir -p out/$SID

STAR \
    --runThreadN $THREADS \
    --genomeDir $GENOME_STARDIR \
    --outFileNamePrefix out/$SID/${SID}__ \
    --readFilesIn $R1 $R2 \
    --readFilesCommand zcat \
    --chimOutType SeparateSAMold \
    --chimSegmentMin 18 \
    --outSAMattributes AS NM MD NH \
    --outSAMunmapped Within

CBAM=$(ls out/$SID/*__Chimeric.out.sam)
ABAM=$(ls out/$SID/*__Aligned.out.sam)

cat $CBAM | egrep -v "^@" | cut -f1 | sort -S 40g -V | uniq > out/$SID/chimericReads.txt
samtools view -hf 4 $ABAM | fgrep -vwf out/$SID/chimericReads.txt | samtools view -b - >out/$SID/${SID}__unmapped.bam

gzip out/$SID/*__Aligned.out.sam &

if [ "$CLUSTER" == "IRIS" ]; then
    PICARD_JAR=/usersoftware/core001/common/RHEL_8/picard/3.4.0/picard.jar
elif [ "$CLUSTER" == "JUNO" ]; then
    PICARD_JAR=/home/socci/Code/Picard/jar/2.25.5/picard.jar
fi

java -jar $PICARD_JAR \
  SortSam SO=coordinate CREATE_INDEX=true I=$CBAM O=${CBAM/.sam/.srt.bam} &

wait

rm $CBAM
