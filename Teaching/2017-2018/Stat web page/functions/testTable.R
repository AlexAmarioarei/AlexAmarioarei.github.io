# Script for creating tables with marks

# Statistica
#------------
library(tidyverse)
library(readxl)


mate = read_excel("students/GRUPE_Matematica_an_III_2017-2018.xlsx", skip = 1)
mate_name = apply(mate[ , 2:4] , 1 , paste , collapse = " ")
grupa_mate = rep(301, length(mate_name))

mate_info = read_excel("students/GRUPE_Matematica-Informatica_an_III_2017-2018.xlsx", skip = 1)
mate_info_name = apply(mate_info[ , 2:4] , 1 , paste , collapse = " ")
grupa_mate_info = rep(311, length(mate_info_name))

mate_aplicata = read_excel("students/GRUPE_Matematici_aplicate_an_III_2017-2018.xlsx", skip = 1)
mate_aplicata_name = apply(mate_aplicata[ , 2:4] , 1 , paste , collapse = " ")
grupa_mate_aplicata = rep(321, length(mate_aplicata_name))


mate_all_name = c(mate_name, mate_info_name, mate_aplicata_name)
grupa_all = c(grupa_mate, grupa_mate_info, grupa_mate_aplicata)

s = length(mate_all_name)

mate_all_name = enc2utf8(mate_all_name)

statistica = data.frame(Nume = character(s), Grupa = numeric(s), Tema_1 = numeric(s), Tema_2 = numeric(s),
                        Tema_3 = numeric(s), Tema_4 = numeric(s), Tema_5 = numeric(s), Tema_6 = numeric(s), 
                        Proiect = numeric(s), Examen = numeric(s), 
                        Total = numeric(s))

statistica$Nume = mate_all_name
statistica$Grupa = grupa_all
statistica$Total = "-"

write.csv(statistica, "students/Tabel_Statistica.csv", row.names = FALSE, fileEncoding = "UTF-8")
# 
# # Informatica
# #-------------
# 
# info_241 = read_excel("Probabilitati si students/Grupe_anul_II_Informatica_2016-2017.xlsx", sheet = 6)
# info_241_name = paste(info_241[[2]], info_241[[4]])
# grupa_info_241 = rep(241, length(info_241_name))
# 
# info_242 = read_excel("Probabilitati si students/Grupe_anul_II_Informatica_2016-2017.xlsx", sheet = 7)
# info_242_name = paste(info_242[[2]], info_242[[4]])
# grupa_info_242 = rep(242, length(info_242_name))
# 
# info_243 = read_excel("Probabilitati si students/Grupe_anul_II_Informatica_2016-2017.xlsx", sheet = 8)
# info_243_name = paste(info_243[[2]], info_243[[4]])
# grupa_info_243 = rep(243, length(info_243_name))
# 
# info_244 = read_excel("Probabilitati si students/Grupe_anul_II_Informatica_2016-2017.xlsx", sheet = 9)
# info_244_name = paste(info_244[[2]], info_244[[4]])
# grupa_info_244 = rep(244, length(info_244_name))
# 
# info_all_name = c(info_241_name, info_242_name, info_243_name, info_244_name)
# grupa_all_info = c(grupa_info_241, grupa_info_242, grupa_info_243, grupa_info_244)
# 
# p = length(info_all_name)
# 
# info_all_name = enc2utf8(info_all_name)
# 
# proba = data.frame(Nume = character(p), Grupa = numeric(p), Tema_1 = numeric(p), Tema_2 = numeric(p),
#                    Tema_3 = numeric(p), Tema_4 = numeric(p), Tema_5 = numeric(p), Tema_6 = numeric(p),
#                    Proiect_1 = numeric(p), Proiect_2 = numeric(p), Examen = numeric(p), 
#                    Total = numeric(p))
# 
# proba$Nume = info_all_name
# proba$Grupa = grupa_all_info
# 
# write.csv(proba, "Probabilitati si students/Tabel_Prob_Stat.csv", row.names = FALSE, fileEncoding = "UTF-8")
