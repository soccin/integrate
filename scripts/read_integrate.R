library(dplyr)
read_integrate<-function(idir) {

    header=readLines(file.path(idir,"bk_sv.vcf")) %>%
        grep("^#C",.,value=T) %>%
        stringr::str_split(.,"\t",simplify=T)

    sampleId=header[len(header)]

    bp=readr::read_tsv(file.path(idir,"breakpoints.tsv"),col_types=cols(.default="c")) |>
        mutate(Junction=paste0(Chr1,":",RNA_BK1,"::",Chr2,":",RNA_BK2)) |>
        rename(`5_Prime`=`#5P`,`3_Prime`=`3P`)

    readr::read_tsv(file.path(idir,"summary.tsv")) |>
        mutate(SampleId=sampleId) |>
        left_join(bp) |>
        select(SampleId,`5_Prime`,`3_Prime`,Junction,everything()) |>
        select(-Fusion_Candidate) |>
        rename(
            Span_RNA=EN_RNA,Split_RNA=SP_RNA,
            Span_DNA_T=EN_DNA_T,Split_DNA_T=SP_DNA_T
        )

}



