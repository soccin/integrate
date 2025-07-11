#!/bin/bash

# BSUB: -o LSF/ -n 12 -R "rusage[mem=12]" -R cmorsc1 -W 24:00

export PATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/opt/bin:$PATH

DBPATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/db

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

