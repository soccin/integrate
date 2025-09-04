# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a bioinformatics pipeline for gene fusion detection using the INTEGRATE algorithm. The pipeline processes RNA-seq and DNA-seq data to identify fusion events through analysis of split reads and spanning reads.

## Key Components

### Core Pipeline Scripts
- `integrateFusionCalls.sh` - Main pipeline script that orchestrates the fusion detection process
- `makeIntegrateProjectFile.R` - Converts BAM manifest CSV files to the format required by INTEGRATE

### Analysis Scripts  
- `scripts/read_integrate.R` - Parses INTEGRATE output files and formats results for downstream analysis
- `scripts/report01.R` - Generates analysis reports from INTEGRATE results

### STAR Alignment Components
- `starmap/starBuildIndex.sh` - Builds STAR genome indices for alignment
- `starmap/starAlignFusion.sh` - Performs STAR alignment optimized for fusion detection  
- `starmap/bundle.*.human_b37` - Cluster-specific configuration files containing reference genome paths

## Architecture

The pipeline follows this workflow:
1. **Input preparation**: BAM manifest files are converted to INTEGRATE format using `makeIntegrateProjectFile.R`
2. **Fusion detection**: Main pipeline `integrateFusionCalls.sh` runs INTEGRATE algorithm with RNA-seq and optional DNA-seq inputs
3. **Result parsing**: `scripts/read_integrate.R` processes raw INTEGRATE output into structured data frames
4. **Analysis**: Additional R scripts generate reports and summaries

## Cluster Environment

The codebase is designed for HPC cluster environments (JUNO/IRIS) with:
- LSF job scheduler integration (BSUB directives in shell scripts)
- Cluster-specific paths and module loading via bundle files
- Dynamic cluster detection in `bin/getClusterName.sh`

## Common Development Commands

### Running the Main Pipeline

**Tumor-only analysis:**
```bash
./integrateFusionCalls.sh SAMPLE_ID /path/to/rna.bam /path/to/tumor.bam
```

**Tumor-normal analysis:**
```bash  
./integrateFusionCalls.sh SAMPLE_ID /path/to/rna.bam /path/to/tumor.bam /path/to/normal.bam
```

### Preparing Input Manifest
```bash
Rscript makeIntegrateProjectFile.R bamManifest.csv
```

### Parsing Results in R
```r
source("scripts/read_integrate.R")
results <- read_integrate("res/SAMPLE_ID/somatic")
```

### Building STAR Index (if needed)
```bash
cd starmap/
./starBuildIndex.sh
```

## Output Structure

Results are organized in `res/SAMPLE_ID/`:
- `somatic/` - Results from tumor-normal analysis
- `tOnly/` - Results from tumor-only analysis

Key output files:
- `summary.tsv` - Primary fusion candidates with tier classifications
- `breakpoints.tsv` - Detailed breakpoint information
- `bk_sv.vcf` - Structural variants in VCF format

## Dependencies

- R with tidyverse, dplyr, readr
- INTEGRATE algorithm (must be in PATH)
- STAR aligner (version 2.7.0a)
- Human genome reference (GRCh37/b37)
- Cluster-specific reference bundles

## Configuration Files

The pipeline uses cluster-specific bundle files that define:
- `GENOME_FASTA` - Reference genome FASTA path
- `GENOME_STARDIR` - STAR index directory  
- `GTF` - Gene annotation file
- Reference paths for INTEGRATE algorithm

## Important Notes

- The pipeline assumes LSF scheduler for job submission
- Bundle files are cluster-specific (JUNO vs IRIS) and contain hardcoded paths
- Input BAM files must be properly aligned with soft-clipping enabled
- Memory requirements: ~12GB RAM, 12 cores typical for LSF jobs
- Runtime: ~24 hours maximum for complex samples
- Do not use EMOJI, do not use EMOJI in commit message, pr message, comments, documentation, ... DO NOT USE EMOJI anywhere