usage<-function(){
    cat("
  usage:makeIntegrateProjectFile.R bamManifest.csv
    - bamManifest.csv headerless csv with the following columns
      PATH,SID,TYPE
      TYPE: T=>tumor
            N=>normal
            R=>RNA
\n")
    quit()
}

argv=commandArgs(trailing=T)

if(len(argv)!=1) {
    usage()
}

require(tidyverse)

argv=commandArgs(trailing=T)
mm=read_csv(argv[1],col_names=c("PATH","SID","TYPE")) %>%
  mutate(TYPE=factor(TYPE,levels=c("R","T","N")))

mm %>% spread(TYPE,PATH) %>% write_tsv("_integrate_manifest.tsv",col_names=F)

