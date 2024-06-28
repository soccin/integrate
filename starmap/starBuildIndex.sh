#!/bin/bash

source bundle.human_b37

export PATH=/opt/common/CentOS_7/star/STAR-2.7.0a/bin:$PATH

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
