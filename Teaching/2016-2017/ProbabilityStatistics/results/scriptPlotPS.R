# Script for graphical illustration of the results 
library(tidyverse)
library(reshape2)
library(plotly)
library(stringr)

# wdPS = "C:/Users/amari/OneDrive/GitHub/AlexAmarioarei.github.io/Teaching/ProbabilityStatistics/results"
# setwd(wdPS)

data = read.csv("results/Tabel_Prob_Stat.csv", stringsAsFactors = FALSE)

data2 = data %>% select(Grupa, Tema_1, Tema_2, Tema_3, Tema_4)

data2$Tema_1 = data2$Tema_1/80*10
data2$Tema_2 = data2$Tema_2/20*10
data2$Tema_3 = data2$Tema_3/50*10
data2$Tema_4 = data2$Tema_4/50*10

data2$Grupa = paste("Grupa", data2$Grupa)

data.melt =  melt(data2, id = c("Grupa"))

data.melt$variable = str_replace_all(data.melt$variable, "_", " ")

p1 = ggplot(data.melt, aes(x = variable, y = value))+
  stat_boxplot(aes(color = variable), geom = "errorbar", width = 0.5) +
  geom_boxplot(aes(color = variable))+
  scale_color_brewer(palette = "Set1")+
  facet_wrap("Grupa")+
  coord_flip()+
  theme_minimal()+
  labs(x = "", y = "", colour = "")+
  theme(legend.position = "none",
        strip.text = element_text(face = "bold", size = "12"))

# ggplotly(p1)
