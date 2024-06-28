argv=commandArgs(trailing=T)
if(len(argv)!=1) {
    cat("\n\tusage: bicMapToSTARMap.R mappingt.txt\n\n")
    quit()
}
require(tidyverse)
outfile=gsub("_sample_mapping.txt","_star_manifest.txt",basename(args))

jobs=read_tsv(argv[1],col_names=F) %>% select(SID=X2,Dir=X4) %>% group_split(SID)

manifest=list()

for(job in jobs) {

    R1=sort(fs::dir_ls(job$Dir,regex="_R1_.*\\.fastq\\.gz"))
    R2=sort(fs::dir_ls(job$Dir,regex="_R2_.*\\.fastq\\.gz"))

    if(any(gsub("_R1_.*","",R1)!=gsub("_R2_.*","",R2))) {
        cat("\n\n\tFATAL ERROR: R1, R2 mismatch\n\n")
        rlang::abort()
    }

    sid=unique(job$SID)

    argR1=paste0(R1,collapse=",")
    argR2=paste0(R2,collapse=",")

    manifest[[sid]]=tibble(SampleID=sid,R1=argR1,R2=argR2)

}

write_tsv(bind_rows(manifest),outfile,col_names=F)
