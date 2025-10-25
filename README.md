# Integrate Fusion Detection Pipeline

A bioinformatics pipeline for detecting gene fusions in cancer samples using the Integrate algorithm. This pipeline processes RNA and DNA sequencing data to identify fusion events through split and spanning read analysis.

## Overview

The Integrate algorithm identifies gene fusions by analyzing:
- **Split reads**: Reads that span fusion breakpoints directly
- **Spanning reads**: Paired-end reads where one mate maps to each fusion partner

## Files

### Main Scripts
- `integrateFusionCalls.sh` - Main pipeline script for running Integrate
- `makeIntegrateProjectFile.R` - Creates manifest files from BAM inputs

### Analysis Scripts
- `scripts/read_integrate.R` - Parse and format Integrate output
- `scripts/report01.R` - Generate analysis reports

### Documentation
- `docs/results.md` - Detailed explanation of split vs spanning reads

### Configuration
- `starmap/` - STAR aligner configuration and reference files

## Usage

### Quick start:

```bash
Rscript integrate/starmap/bicMapToSTARMap.R ../meta/Proj_17297_sample_mapping.txt
cat Proj_17297_star_manifest.txt  | xargs -n 3 bsub -o LSF/ -J STARf -n 18 -W 12:00 ./integrate/starmap/starAlignFusion.sh 
#
# Create intergrate manifest
# Path,SampleID,Type[T,N,R]
#
Rscript integrate/makeIntegrateProjectFile.R bams

cat _integrate_manifest.tsv | xargs -n [34] bsub -o LSF/ -n 12 -R "rusage[mem=12]" -R cmorsc1 -W 24:00 ./integrate/integrateFusionCalls.sh
```

N.B., 3 if no matched normals (SID,RNA.BAM,TUMOR.BAM), 4 if WGS T/N pairs.

### 0. Star chimeric maps

First need to prepare the correct BAM's using the correction options to STAR.

```bash
Rscript integrate/starmap/bicMapToSTARMap.R BIC_SAMPLE_MAPPING.txt
cat {PROJNO}_star_manifest.txt | xargs -n 3 bsub -o LSF/ -J STARf -n 18 -W 12:00 ./integrate/starmap/starAlignFusion.sh 
```

### 1. Prepare manifest file

Input CSV format **NO HEADER**
in this column order
  PATH
  SID
  TYPE

eg
```
/path/to/rna.bam,SAMPLE01,R
/path/to/tumor.bam,SAMPLE01,T
/path/to/normal.bam,SAMPLE01,N
```

Where TYPE:
- `R` = RNA sequencing data
- `T` = Tumor DNA sequencing data  
- `N` = Normal DNA sequencing data

- Again **NO HEADER**.

- For the RNA bam you need to use `.*Chimeric.out.srt.bam`

Then run

```bash
Rscript makeIntegrateProjectFile.R bamManifest.csv
```

### 2. Run fusion detection

**Tumor-only analysis:**
```bash
./integrateFusionCalls.sh SAMPLE_ID RNA_BAM TUMOR_BAM
```

**Somatic analysis (with matched normal):**
```bash
./integrateFusionCalls.sh SAMPLE_ID RNA_BAM TUMOR_BAM NORMAL_BAM
```

### 3. Parse results

```r
source("scripts/read_integrate.R")
results <- read_integrate("res/SAMPLE_ID/somatic")
```

## Output

Results are generated in:
- `res/SAMPLE_ID/somatic/` - For tumor/normal pairs
- `res/SAMPLE_ID/tOnly/` - For tumor-only analysis

Key output files:
- `summary.tsv` - Summary of detected fusions
- `breakpoints.tsv` - Detailed breakpoint information
- `bk_sv.vcf` - Structural variants in VCF format

## Requirements

- R with tidyverse
- Integrate algorithm (configured in PATH)
- STAR aligner
- Human genome reference (GRCh37/b37)

## LSF Configuration

The pipeline includes LSF batch system configuration:
- 12 cores
- 12GB memory
- 24 hour runtime
- cmorsc1 resource requirement
