usage<-function(){
    cat("\n\tusage:makeProjectFile.R starManifest.csv tempoManifest.tsv tempoPairing.txt\n\n")
    quit()
}

argv=commandArgs(trailing=T)

if(len(argv)!=3) {
    usage()
}

require(tidyverse)

rna=read_csv(argv[1],col_names=c("SAMPLE","RBAM"))
dna=read_tsv(argv[2])
pairs=read_tsv(argv[3])

tbams=dna %>%
    filter(SAMPLE %in% pairs$TUMOR_ID) %>%
    select(SAMPLE,TBAM=BAM) %>%
    mutate(SAMPLE=gsub("C-......_","",SAMPLE))

nbams=dna %>%
    filter(SAMPLE %in% pairs$NORMAL_ID) %>%
    select(SAMPLE,NBAM=BAM) %>%
    mutate(SAMPLE=gsub("C-......_","",SAMPLE)) %>%
    mutate(SAMPLE=gsub("-N$","-T",SAMPLE))

manifest=rna %>%
    mutate(SAMPLE=paste0(SAMPLE,"-T")) %>%
    left_join(tbams) %>%
    filter(!is.na(TBAM)) %>%
    left_join(nbams) %>%
    filter(!is.na(NBAM))

write_tsv(manifest,"_integrate_manifest.txt",col_names=F)

