# INTEGRATE RNA+DNA Fusion Detection Pipeline - Complete Documentation

## Overview

INTEGRATE is a highly sensitive and accurate gene fusion discovery tool that combines RNA-seq and whole genome sequencing (WGS) data to detect gene fusions with exact fusion junctions and genomic breakpoints. Unlike other tools that analyze RNA-seq and WGS data separately, INTEGRATE leverages orthogonal validation from both data types to achieve superior sensitivity and specificity.

### Key Features
- **Integrated approach**: Combines RNA-seq and WGS data for enhanced accuracy
- **High sensitivity**: Detects both highly expressed and lowly expressed gene fusions
- **Exact breakpoints**: Provides precise fusion junctions and genomic breakpoints
- **Flexible input**: Works with RNA-seq only data or combined RNA-seq + WGS data
- **Tiered classification**: Systematic confidence scoring based on evidence strength

## Understanding Read Evidence Types

Before diving into the tier system, it's essential to understand the two fundamental types of sequencing evidence that INTEGRATE uses to detect gene fusions:

### **Spanning Reads**
- **Definition**: Individual reads that cross the actual fusion junction
- **Characteristic**: One single read partially aligns to both fusion partner genes
- **Evidence strength**: Direct evidence of the fusion junction sequence
- **Detection**: Read contains sequences from both Gene A and Gene B
- **Example**: A 100bp read where nucleotides 1-60 map to Gene A and nucleotides 61-100 map to Gene B

```
Gene A ████████████████████▼ Fusion Junction
Gene B                      ▲████████████████████
       ████████████████████████████████████████  <- Spanning Read
       Gene A portion    |    Gene B portion
```

### **Encompassing Reads** 
- **Definition**: Paired-end reads where each mate aligns to a different fusion partner
- **Characteristic**: Read pair "encompasses" or surrounds the fusion junction
- **Evidence strength**: Indirect evidence suggesting abnormal gene proximity
- **Detection**: Mate 1 maps to Gene A, Mate 2 maps to Gene B (or vice versa)
- **Example**: In a paired-end sequencing run, one read maps to Gene A and its paired mate maps to Gene B

```
Gene A ████████████████████▼ Fusion Junction  
                      Read 1 ████████████████████
Gene B                      ▲████████████████████
       ████████████████████ Read 2
       <- Encompassing Read Pair ->
```

### **Key Differences**

| Aspect | Spanning Reads | Encompassing Reads |
|--------|----------------|-------------------|
| **Junction Evidence** | Direct | Indirect |
| **Sequence Information** | Contains fusion breakpoint sequence | Suggests gene proximity |
| **Validation Value** | High - can design PCR primers | Moderate - supports fusion hypothesis |
| **False Positive Rate** | Lower | Higher |
| **Technical Requirements** | Requires junction-crossing reads | Requires proper paired-end mapping |

### **RNA-seq vs. WGS Read Evidence**

#### **RNA-seq Reads**
- **Spanning**: Reads crossing expressed fusion transcript junctions
- **Encompassing**: Read pairs mapping to different exons of fusion partners
- **Advantage**: Direct evidence of expressed fusion transcripts
- **Limitation**: Only detects expressed fusions

#### **WGS Reads**
- **Spanning**: Reads crossing genomic breakpoints
- **Encompassing**: Read pairs mapping to genomic regions flanking breakpoints  
- **Advantage**: Detects genomic rearrangements regardless of expression
- **Limitation**: More complex due to repetitive regions and larger genomic context

### **Why Both Types Matter**
- **Spanning reads** provide definitive evidence of the exact fusion sequence
- **Encompassing reads** provide supporting evidence and help define breakpoint regions
- **Combined evidence** (both types from both RNA-seq and WGS) gives highest confidence
- **Single type evidence** may indicate technical limitations or unusual fusion characteristics

## Complete Tier Classification System

INTEGRATE uses a 7-tier system to classify gene fusion candidates based on the level and type of sequencing support. This provides crucial insights into fusion confidence and formation mechanisms.

### **Canonical Exon-Intron Boundaries (Tiers 1-3)**
*Gene fusions with junctions at canonical exon-intron boundaries*

#### **Tier 1 - Highest Confidence**
- **Evidence**: Both encompassing AND spanning reads from BOTH RNA-seq AND WGS
- **Confidence**: Highest reliability - gold standard fusions
- **Interpretation**: Strong genomic rearrangement with expressed fusion transcript
- **Validation rate**: ~95% in published studies

#### **Tier 2 - High Confidence** 
- **Evidence**: Both RNA-seq and WGS support, BUT only encompassing WGS reads (no spanning WGS reads)
- **Confidence**: High reliability
- **Interpretation**: Genomic rearrangement present but spanning WGS reads not detected
- **Validation rate**: ~95% (combined with Tier 1)

#### **Tier 3 - Moderate Confidence**
- **Evidence**: Only RNA-seq support (both encompassing and spanning reads), NO WGS support
- **Subtypes**:
  - **Tier 3-nr**: Non-read-through gene fusions (~77% validation rate)
  - **Tier 3-r**: Read-through transcripts (different exon usage pattern)
- **Confidence**: Moderate - expressed fusion but no genomic evidence
- **Interpretation**: May be transcriptional events, low-level genomic events, or technical artifacts

### **Non-Canonical Boundaries (Tiers 4-6)**
*Gene fusions with junctions NOT at canonical exon-intron boundaries (introns or truncated exons)*

#### **Tier 4 - High Confidence Non-Canonical**
- **Evidence**: Both encompassing AND spanning reads from BOTH RNA-seq AND WGS  
- **Confidence**: High reliability for non-canonical fusions
- **Interpretation**: Complex rearrangements with breakpoints in introns/truncated exons

#### **Tier 5 - Moderate Confidence Non-Canonical**
- **Evidence**: Both RNA-seq support AND encompassing WGS reads (no spanning WGS)
- **Confidence**: Moderate reliability
- **Interpretation**: Genomic support present but limited WGS evidence

#### **Tier 6 - Lower Confidence Non-Canonical**
- **Evidence**: Only RNA-seq support (no WGS), non-canonical boundaries
- **Subtypes**:
  - **Tier 6-nr**: Non-read-through 
  - **Tier 6-r**: Read-through events
- **Confidence**: Lower reliability
- **Interpretation**: Requires careful evaluation - may include artifacts

### **Germline Events (Tier 7)**
#### **Tier 7 - Likely Germline**
- **Evidence**: Candidates found in tumor samples that are also likely present in matched normal samples
- **Confidence**: Low for somatic relevance
- **Interpretation**: Germline variants, not somatic tumor events
- **Action**: Usually filtered out for cancer studies

### **RNA-seq Only Mode**
When only RNA-seq data is available:
- **Tier 3**: Canonical boundaries (both 3-nr and 3-r)
- **Tier 6**: Non-canonical boundaries (both 6-nr and 6-r)

## Key Output Files

### 1. **summary.tsv** - Primary Results File
Contains essential fusion characteristics:
- **5p/3p gene names**: Fusion partners (5' to 3' direction)
- **Reciprocal**: Whether reciprocal fusion detected (Y/N)  
- **Tier**: Confidence level (1-7)
- **Type**: Fusion class (inter_chromosomal/intra_chromosomal/read_through)
- **Read counts**: Numbers of supporting encompassing/spanning RNA-seq/WGS reads
- **Isoforms**: List of fusion transcript variants

### 2. **fusions.bedpe** - Standardized Format
ICGC-TCGA DREAM SMC-RNA challenge format with:
- Genomic coordinates of fusion partners
- Gene names and fusion identifiers  
- Strand information
- Expression quantification

### 3. **exons.tsv** - Sequence Details
- Exon sequences at fusion junctions (canonical boundaries only)
- Useful for primer design and manual validation

### 4. **breakpoints.tsv** - Genomic Context
- Coordinates of fusion junctions and genomic breakpoints
- Most informative when both RNA-seq and WGS data available

### 5. **reads.txt** - Supporting Evidence
- All encompassing and spanning reads for each fusion
- Grouped by isoforms for same gene pair
- Essential for manual inspection and validation

## Interpretation Guidelines

### **High Priority Fusions (Recommend Validation)**
1. **Tier 1**: All candidates - highest confidence
2. **Tier 2**: Most candidates - high confidence  
3. **Tier 4**: Non-canonical but both RNA+DNA support
4. **Recurrent fusions**: Same fusion in multiple samples
5. **Known oncogenes**: Fusions involving cancer driver genes

### **Moderate Priority Fusions (Selective Validation)**
1. **Tier 3-nr**: Non-read-through with good RNA-seq support
2. **Tier 5**: Non-canonical with DNA support
3. **Highly expressed**: Strong RNA-seq read support regardless of tier

### **Lower Priority Fusions (Careful Evaluation)**
1. **Tier 3-r & 6-r**: Read-through events (often regulatory)
2. **Tier 6-nr**: Non-canonical RNA-only support  
3. **Single read support**: Fusions with minimal evidence
4. **Promiscuous genes**: Genes frequently appearing in fusions

### **Filter Out**
1. **Tier 7**: Germline events (unless studying germline fusions)
2. **Extremely high frequency**: Unrealistic recurrence suggesting artifacts
3. **Known false positives**: Fusions in blacklist databases

## Quality Control Recommendations

### **Sample-Level QC**
- Check total number of fusion candidates (typically 10-200 per sample)
- Verify read alignment quality and split-read representation
- Confirm appropriate tier distribution (more Tier 1-3 than 4-6)

### **Cohort-Level QC**  
- Monitor fusion frequency across samples
- Identify batch effects or systematic artifacts
- Use voting methods for borderline candidates with support across multiple samples

### **Validation Strategy**
1. **RT-PCR**: Standard validation for Tier 1-2 fusions
2. **Sanger sequencing**: Confirm exact breakpoints
3. **Functional studies**: For potential driver fusions
4. **Orthogonal methods**: FISH for structural validation

## Best Practices

### **Input Data Requirements**
- **RNA-seq**: Paired-end reads, adequate depth (>30M reads)
- **WGS**: Tumor and optionally normal samples  
- **Quality**: Properly aligned BAMs with soft-clipping enabled
- **Annotation**: Current gene annotation matching reference build

### **Parameter Optimization**
- **-cfn**: Adjust spanning read threshold for non-canonical fusions
- **-minW**: Lower for sensitive detection in low-coverage samples  
- **-minIntra**: Tune read-through vs. deletion distinction
- **-rt**: Set normal/tumor ratio threshold for germline filtering

### **Computational Resources**
- **Memory**: approximately 32GB RAM typical requirement
- **Runtime**: 2-4 hours per sample with both RNA+DNA
- **Storage**: Plan for large intermediate files during processing

## Integration with INTEGRATE Suite

### **INTEGRATE-Vis**: Visualization Tool
- Generate publication-quality fusion graphics
- Visualize transcript structure, protein domains, expression patterns
- Support for cohort-level expression analysis

### **INTEGRATE-Neo**: Neoantigen Discovery  
- Identify fusion-derived neoantigens for immunotherapy
- HLA allele-specific epitope prediction
- Integration with personalized cancer vaccine workflows

---

**Note**: This tier system provides a systematic framework for prioritizing gene fusion candidates. Higher tiers generally indicate higher confidence, but biological context, expression levels, and known oncogene involvement should also guide validation decisions. Always validate promising candidates experimentally before making clinical or research conclusions.

## Bibliography

Zhang, J., & Maher, C. A. (2020). Gene Fusion Discovery with INTEGRATE. In H. Li & J. Elfman (Eds.), *Chimeric RNA: Methods and Protocols* (pp. 41-68). Methods in Molecular Biology, vol. 2079. Springer Science+Business Media, LLC. https://doi.org/10.1007/978-1-4939-9904-0_4

### Related Publications

Zhang, J., White, N. M., Schmidt, H. K., Fulton, R. S., Tomlinson, C., Warren, W. C., Wilson, R. K., & Maher, C. A. (2016). INTEGRATE: gene fusion discovery using whole genome and transcriptome data. *Genome Research*, 26(1), 108-118. https://doi.org/10.1101/gr.186114.114

Zhang, J., Gao, T., & Maher, C. A. (2017). INTEGRATE-Vis: a tool for comprehensive gene fusion visualization. *Scientific Reports*, 7(1), 17808. https://doi.org/10.1038/s41598-017-18257-2