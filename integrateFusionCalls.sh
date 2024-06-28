#!/bin/bash

export PATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/opt/bin:$PATH

DBPATH=/juno/work/bic/socci/Work/Users/ElenitK/Wur4/Integrate/db

. $DBPATH/bundle.human_b37

ARGC=$#


SID=$1
RNA_BAM=$(realpath $2)
DNA_TUMOR_BAM=$(realpath $3)

if [ $ARGC == "4" ]; then

    DNA_NORMAL_BAM=$(realpath $4)

else

    DNA_NORMAL_BAM=""

fi

usage () {
    echo "usage: integrateFusionCalls.sh RNA_BAM DNA_TUMOR_BAM [DNA_NORMAL_BAM]"
}

if [ ! -e "$RNA_BAM" ]; then
    usage
    echo "RNA_BAM = ["${RNA_BAM}"] does not exists"
    exit
fi

if [ ! -e "$DNA_TUMOR_BAM" ]; then
    usage
    echo "BAM = ["${DNA_TUMOR_BAM}"] does not exists"
    exit
fi

if [ "$DNA_NORMAL_BAM" != "" ]; then
    if [ ! -e "$DNA_NORMAL_BAM" ]; then
        usage
        echo "BAM = ["${DNA_NORMAL_BAM}"] does not exists"
        exit
    fi
fi

if [ $ARGC == "4" ]; then

    ODIR=res/$SID/somatic

else

    ODIR=res/$SID/tOnly

fi

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

