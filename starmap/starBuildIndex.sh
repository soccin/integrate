#!/bin/bash

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

# The basic options to generate genome indices are as follows:
# --runThreadN NumberOfThreads
# --runMode genomeGenerate
# --genomeDir /path/to/genomeDir
# --genomeFastaFiles /path/to/genome/fasta1 /path/to/genome/fasta2 ...
# --sjdbGTFfile /path/to/annotations.gtf
# --sjdbOverhang ReadLength-1

STAR \
    --runThreadN $THREADS \
    --runMode genomeGenerate \
    --genomeDir $GENOME_STARDIR \
    --genomeFastaFiles $GENOME_FASTA \
    --sjdbGTFfile $GTF \
    --sjdbOverhang 100
