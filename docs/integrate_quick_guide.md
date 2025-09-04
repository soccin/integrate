# INTEGRATE Results Quick Reference Guide

## INTEGRATE Tier System

Gene fusion candidates are classified into 7 tiers based on sequencing evidence strength and junction type:

### Combined RNA-seq + WGS Analysis

| Tier | Junction Type | RNA-seq Evidence | WGS Evidence | Confidence Level |
|------|---------------|------------------|--------------|------------------|
| **1** | Canonical boundaries | Encompassing + Spanning | Encompassing + Spanning | **Highest** |
| **2** | Canonical boundaries | Encompassing + Spanning | Encompassing only | **High** |
| **3** | Canonical boundaries | Encompassing + Spanning | None | **Moderate** |
| **4** | Non-canonical boundaries | Encompassing + Spanning | Encompassing + Spanning | **High** |
| **5** | Non-canonical boundaries | Encompassing + Spanning | Encompassing only | **Moderate** |
| **6** | Non-canonical boundaries | Encompassing + Spanning | None | **Lower** |
| **7** | Any | Any | Any | **Germline** |

### RNA-seq Only Analysis
When only RNA-seq data is available:
- **Tier 3**: Canonical exon-intron boundaries
- **Tier 6**: Non-canonical boundaries (introns/truncated exons)

### Boundary Types
- **Canonical boundaries**: Standard exon-intron splice sites
- **Non-canonical boundaries**: Breakpoints within introns or truncated exons
- **Tier 7**: Likely germline events (present in both tumor and normal samples)

---

\newpage

## Understanding Read Evidence Types

### **Spanning Reads**
- **What they are**: Individual reads that cross the fusion junction
- **Evidence type**: **Direct** - contains actual fusion breakpoint sequence
- **Strength**: Strongest evidence for fusion existence
- **Use**: Can design validation PCR primers from junction sequence

```
Gene A ████████████████████▼                      <- Fusion Junction
Gene B                     ▲████████████████████
           █████████████████████████████████      <- Spanning Read
           Gene A portion  |  Gene B portion
```

### **Encompassing Reads**
- **What they are**: Paired reads where each mate maps to a different gene
- **Evidence type**: **Indirect** - suggests abnormal gene proximity  
- **Strength**: Supporting evidence for fusion hypothesis
- **Use**: Helps confirm fusion candidates and define breakpoint regions

```
Gene A ████████████████████▼                      <- Fusion Junction
Gene B                     ▲████████████████████
         ████████████            ████████████     <- Encompassing Read Pair
        Gene A portion     |    Gene B portion
```

### **Why Both Matter**
- **Spanning reads**: Prove the fusion junction exists and provide exact sequence
- **Encompassing reads**: Support the fusion hypothesis and help map breakpoint regions
- **Combined evidence**: Higher confidence when both types are present from both RNA-seq and WGS

---

## Quick Interpretation Guide

### **High Priority for Validation**
- **Tier 1 & 2**: Strongest evidence with both RNA and DNA support
- **Tier 4**: Non-canonical but solid dual evidence
- **Recurrent fusions**: Same fusion found across multiple samples

### **Moderate Priority**
- **Tier 3**: Good RNA evidence, may be real but needs validation
- **Tier 5**: Non-canonical with some DNA support

### **Lower Priority**
- **Tier 6**: RNA-only evidence with non-canonical boundaries
- **Very low read counts**: Minimal supporting evidence

### **Usually Filter Out**
- **Tier 7**: Germline events (not tumor-specific)
- **Known artifacts**: Frequent false positives in databases

---

## Key Points to Remember

1. **Higher tiers = higher confidence**, but consider biological context
2. **Spanning reads > encompassing reads** for validation confidence  
3. **RNA+WGS evidence > RNA-only** for fusion authenticity
4. **Canonical boundaries > non-canonical** for typical gene fusions
5. **Always validate promising candidates** experimentally before conclusions

---

*Based on: Zhang, J., & Maher, C. A. (2020). Gene Fusion Discovery with INTEGRATE. Methods in Molecular Biology, 2079, 41-68.*