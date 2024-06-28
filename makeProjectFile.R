usage<-function(){
    cat("\n\tusage:makeProjectFile.R starManifest.csv tempoManifest.tsv\n\n")
    quit()
}

argv=commandArgs(trailing=T)

if(len(argv)!=2) {
    usage()
}

require(tidyverse)
