require(tidyverse)
source("integrate/scripts/read_integrate.R")

TYPE="somatic"
files=fs::dir_ls("res",recur=T,regex="somatic$")
if(len(files)<1) {
   files=fs::dir_ls("res",recur=T,regex="tOnly$")
   TYPE="TumorOnly"
}
dd=map(files,read_integrate) %>% bind_rows

coverage_ranks=dd %>%
    mutate(RID=row_number()) %>%
    select(RID,matches("(Span|Split)")) %>%
    mutate_at(vars(matches("(Span|Split)")),~rank(.,ties.method="min")/nrow(dd)) %>%
    rename_at(vars(matches("(Span|Split)")),~cc("Rank",.)) %>%
    mutate(SumRanks=rowSums(.[2:5])) %>%
    select(RID,SumRanks)

tbl0=dd %>%
    mutate(RID=row_number()) %>%
    left_join(coverage_ranks) %>%
    arrange(Tier,desc(SumRanks)) %>%
    select(-RID) %>%
    ungroup %>%
    select(-Splicings,Splicings)

tbl0a=tbl0 %>% filter(Span_DNA_T>0 & Split_DNA_T>0)

# forteFusionFile=fs::dir_ls(".",regex="__FusionTableV.__allEvents.csv",recur=T)

# if(len(forteFusionFile)==0) {
#     cat("\nERROR: Can not find Forte Fusion output\n")
#     cat("*__FusionTableV?__allEvents.csv\n\n")
#     quit()
# }

# mf=read_csv(forteFusionFile) %>%
#     select(1:11) %>%
#     mutate(Junction=gsub(":.::","::",Junction)%>%gsub(":.$","",.)%>%gsub("chr","",.)) %>%
#     mutate(Sample=gsub("s_","",Sample)) %>%
#     mutate(SampleId=Sample) %>%
#     select(SampleId,everything())

integrateCols=1:which(colnames(dd)=="Splicings")

projNo=grep("Proj_",strsplit(getwd(),"/")[[1]],value=T)

fusionFreq=tbl0 %>%
    mutate(Fusion=paste0(`5_Prime`,"::",`3_Prime`)) %>%
    select(SampleId,Fusion) %>%
    distinct() %>%
    group_by(Fusion) %>%
    summarize(N=n(),Samples=paste0(SampleId,collapse=";")) %>%
    arrange(desc(N)) %>%
    filter(N>1)

genesFreq=tbl0 %>%
    select(SampleId,`5_Prime`,`3_Prime`) %>%
    gather(End,Gene,-SampleId) %>%
    select(-End) %>%
    distinct %>%
    group_by(Gene) %>%
    summarize(N=n(),Samples=paste0(SampleId,collapse=";")) %>%
    arrange(desc(N)) %>%
    filter(N>1)

sheets=list()
if(nrow(fusionFreq)>0) {
  sheets=c(sheets,list(FusionFreq=fusionFreq))
}
if(nrow(genesFreq)>0) {
  sheets=c(sheets,list(GeneFreq=genesFreq))
}
sheets=c(sheets,list(IntegrateAll=tbl0))

openxlsx::write.xlsx(
  sheets,
  cc(projNo,"IntegrateFusions",TYPE,"v5.xlsx")
)

