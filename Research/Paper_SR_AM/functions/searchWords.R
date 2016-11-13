# library(readxl)
# library(tidyr)
# library(dplyr)
# library(stringr)
# library(stringi)


# rm(list = ls())

# setwd("F:/INCDSB/Sectorial Bioeconomie/Raportare Faza 15 iulie 2016/dataInBioTrans")

# wdSR = "F:/OneDrive/lucrari lucrate in Romania/Lucrare Statistical Reviews Mihaela"

# setwd(wdSR)

pubYearStart = "1998"
pubYearFinish = "2016"

doc1 = read.csv("dataIn/cuvinte.csv", stringsAsFactors = FALSE)

names(doc1) = c("ID","ENG")

sir1 = "AUTHKEY({"

for (i in 1:(length(doc1$ENG)-1))
{
  sir1 = paste(sir1, doc1$ENG[i], "} OR {", sep="")
}

sir1 = paste(sir1, doc1$ENG[length(doc1$ENG)], "}) AND PUBYEAR > ", pubYearStart, " AND PUBYEAR < ", pubYearFinish, sep="")


sir2 = c(rep("", length(doc1$ENG)+1))

sir2[1] = sir1

for (i in 1:length(doc1$ENG)){
  sir2[i+1] = paste0('AUTHKEY("', doc1$ENG[i], '") AND PUBYEAR > ', pubYearStart, " AND PUBYEAR < ", pubYearFinish)
}


# Save the research words

write.csv(sir2, file = "dataOut/searchScopusSR.csv")

