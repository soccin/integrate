# Integrate output

## Split vs Spanning

1. Split reads  
    - A split read is a single sequencing read that harbors the fusion boundary within itself.

    - One part of the read aligns to one gene, and the other part aligns to the other gene involved in the fusion.

    - Essentially, the read itself crosses the breakpoint between the two genes.

    - These reads provide direct evidence for the fusion event and can help pinpoint the exact breakpoint. 

2. Spanning reads
    - A spanning read refers to a paired-end read where one read of the pair aligns to one gene and the other read of the pair aligns to the other gene involved in the fusion.

    - The fusion boundary is located within the insert segment (the unsequenced portion) between the two reads of the pair.

    - They provide indirect evidence of the fusion event by showing that the two genes are located in close proximity on the same transcript.

    - These reads are also referred to as discordant read pairs or bridging read pairs.
