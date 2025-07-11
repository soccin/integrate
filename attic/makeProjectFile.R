usage<-function(){
    cat("\n\tusage:makeProjectFile.R tempoManifest.tsv tempoPairing.txt\n\n")
    quit()
}

argv=commandArgs(trailing=T)

if(len(argv)!=2) {
    usage()
}

require(tidyverse)

# _Chimeric.out.srt.bam

rnaBams=fs::dir_ls(recur=T,regex="_Chimeric.out.srt.bam")
rna=tibble(
    SAMPLE=basename(rnaBams) %>% gsub("__Chimeric.out.srt.bam$","",.),
    RBAM=rnaBams
)

dna=read_tsv(argv[1])
pairs=read_tsv(argv[2])

tbams=dna %>%
    filter(SAMPLE %in% pairs$TUMOR_ID) %>%
    select(SAMPLE,TBAM=BAM) %>%
    mutate(SAMPLE=gsub("C-......_","",SAMPLE))

tumorMarker=unique(stringr::str_extract(tbams$SAMPLE,"..$"))
if(len(tumorMarker)!=1) {
    cat("\n\n   Ambiguous tumorMarker [",tumorMarker,"]\n\n")
    rlang::abort("FATAL::ERROR")
}

nbams=dna %>%
    filter(SAMPLE %in% pairs$NORMAL_ID) %>%
    select(SAMPLE,NBAM=BAM) %>%
    mutate(SAMPLE=gsub("C-......_","",SAMPLE)) %>%
    mutate(SAMPLE=gsub(".N$",tumorMarker,SAMPLE))

manifest=rna %>%
    mutate(SAMPLE=paste0(SAMPLE,tumorMarker)) %>%
    left_join(tbams) %>%
    filter(!is.na(TBAM)) %>%
    left_join(nbams) %>%
    filter(!is.na(NBAM))

write_tsv(manifest,"_integrate_manifest.txt",col_names=F)
