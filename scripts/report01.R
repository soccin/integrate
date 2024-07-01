require(tidyverse)
source("read_integrate.R")
dd=map(fs::dir_ls("res",recur=T,regex="tOnly$"),read_integrate) %>% bind_rows

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

key=readxl::read_xlsx("Proj_KEJ.S01__Manifest.xlsx") %>% select(PID,Sample=RNASeq)

mf=read_csv("Proj_14879_B__FusionTableV3__allEvents.csv") %>%
    select(1:11) %>%
    mutate(Junction=gsub(":.::","::",Junction)%>%gsub(":.$","",.)%>%gsub("chr","",.)) %>%
    mutate(Sample=gsub("s_","",Sample)) %>%
    left_join(key) %>%
    rename(SampleId=PID)

tbl1=left_join(dd %>% select(1:12),mf) %>%
    filter(!is.na(Sample)) %>%
    arrange(Tier,desc(Split_RNA)) %>%
    select(-Splicings,Splicings)

tblHC=tbl1 %>% filter(!is.na(Sample) & Span_DNA_T>0)

# tbl2=dd %>%
#     mutate(Fusion=paste0(`5_Prime`,"::",`3_Prime`)) %>%
#     rename(JunctionI=Junction) %>%
#     select(1:12,Fusion) %>%
#     left_join(distinct(mf,Fusion,.keep_all=T)) %>%
#     filter(!is.na(Sample)) %>%
#     arrange(Tier,desc(Split_RNA)) %>%
#     select(-Splicings,Splicings)

openxlsx::write.xlsx(
            list(
                IntegrateAll=tbl0,
                ExactJuncMatch=tbl1,
                HighConf=tblHC
            ),
            "Proj_KEJ.S01_IntegrateFusions_TumOnly_03.xlsx")

