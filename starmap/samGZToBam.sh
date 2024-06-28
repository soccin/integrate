#!/bin/bash

SAM=$1

zcat $SAM |
    picardV2 SortSam SO=coordinate CREATE_INDEX=true \
    I=/dev/stdin \
    O=${SAM/.sam.gz/.bam}

