#!/bin/bash

# bsub -o LSF/ -J STARf -n 18 -W 359

SDIR=$(dirname "$(readlink -f "$0")")

set -e

module load samtools

. $SDIR/../bin/getClusterName.sh

BUNDLE_FILE="bundle.${CLUSTER}.human_b37"
if [ ! -f "$BUNDLE_FILE" ]; then
    echo -e "\n   ERROR: Bundle file $BUNDLE_FILE does not exist\n"
    exit 1
fi
source "$BUNDLE_FILE"

if [ "$CLUSTER" == "JUNO" ]; then
  export PATH=/opt/common/CentOS_7/star/STAR-2.7.0a/bin:$PATH
elif [ "$CLUSTER" == "IRIS" ]; then
  export PATH=/usersoftware/core001/common/RHEL_8/star/2.7.0a/bin:$PATH
else
  echo -e "\n   UNKNOWN CLUSTER" $CLUSTER "\n\n"
  exit 1
fi

THREADS=16

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

cat $CBAM | egrep -v "^@" | cut -f1 | sort -S 12g -V | uniq > out/$SID/chimericReads.txt
samtools view -hf 4 $ABAM | fgrep -vwf out/$SID/chimericReads.txt | samtools view -b - >out/$SID/${SID}__unmapped.bam

gzip out/$SID/*__Aligned.out.sam &
picardV2 SortSam SO=coordinate CREATE_INDEX=true I=$CBAM O=${CBAM/.sam/.srt.bam} &

wait

rm $CBAM
