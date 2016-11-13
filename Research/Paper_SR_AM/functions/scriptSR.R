# Script Paper Statistical Reviews 
#====================================

# Set the working directory
#--------------------------

wdSR = "F:/OneDrive/lucrari lucrate in Romania/Lucrare Statistical Reviews Mihaela"

setwd(wdSR)

# Load some functions
#--------------------
source("functions/CapitalizeWord.R")
source("functions/deleteNA.R")
source("functions/ensure_library.R")
source("functions/figureNumber.R")
source("functions/multiplot.R")
source("functions/tableNumber.R")
source("functions/comp_hindex.R")

# Load packages 
# General packages
#-----------------
require_library("readxl")
require_library("tidyr")
require_library("dplyr")
require_library("stringr")
require_library("stringi")
require_library("ggplot2")
require_library("knitr")
require_library("reshape2")

# Maps
#-----------------
require_library("tmap")
require_library("ggmap")
require_library("ggrepel")


# Read data into a single file: dat.combined
#--------------------------------------------

words = read.csv("dataIn/cuvinte.csv", stringsAsFactors = FALSE)
names(words) = c("ID","Key")

words$Key2 = str_replace(words$Key, " ", "_")

dat.combined = read.csv(paste0("dataIn/Words/", words$Key2[1],".csv"), stringsAsFactors = FALSE)
dat.combined$Word = words$Key[1]

hgindex = comp_hgindex(dat.combined)

dat.combined$Hindex = hgindex[1]
dat.combined$Gindex = hgindex[2]


for (i in 2:length(words$Key)){
  print(i)
  dat = read.csv(paste0("dataIn/Words/", words$Key2[i],".csv"), stringsAsFactors = FALSE)
  dat$Word = words$Key[i]
  
  hgindex = comp_hgindex(dat)
  
  dat$Hindex = hgindex[1]
  dat$Gindex = hgindex[2]
  
  dat.combined = rbind(dat.combined, dat)
}

# writing the file 
write.csv(dat.combined, "dataOut/data_Combined.csv")

# table with the number of papers and citations per keyword
dat.tab_wc = dat.combined %>% group_by(Word, Hindex, Gindex) %>% summarise(count = n(), cited = sum(as.numeric(Cited.by), na.rm = TRUE))

# Summarise Data
#-------------------

dat.Year.Words = dat.combined %>% group_by(Word, Year) %>% summarise(count = n())

dat.Year.Words2 = data.frame(Year = rep("", length(unique(dat.Year.Words$Word))), 
                             count = rep("", length(unique(dat.Year.Words$Word))), 
                             Word = rep("", length(unique(dat.Year.Words$Word))))

# Plot 1 - number of papers 
#+++++++++++++++++++++++++++

dat.Year.Words2$Year = rep(2015, length(unique(dat.Year.Words$Word)))
dat.Year.Words2$count = dat.Year.Words$count[which(dat.Year.Words$Year == "2015")]
dat.Year.Words2$Word = unique(dat.Year.Words$Word)

ggplot(dat.Year.Words, aes(x = Year, y = count)) + 
  geom_text_repel(aes(x = Year, 
                      y = count, 
                      label = Word,
                      colour = Word), 
                  data = dat.Year.Words2,
                  size = 2.75, 
                  fontface = 'bold',
                  box.padding = unit(0.5, 'lines'),
                  point.padding = unit(1.6, 'lines'),
                  segment.color = '#555555',
                  arrow = arrow(length = unit(0.01, 'npc')))+
  geom_line(aes(color = Word)) + 
  geom_point(aes(color = Word)) + 
  theme_bw()+
  labs(x = "", y = "Number of publications", colour = "Search Keywords")+
  scale_x_continuous(breaks = c(1999:2015), labels = as.character(1999:2015))+
  theme(legend.title = element_text(size = 10), 
        axis.title.y = element_text(size = 10),
        legend.text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(size = 6),
        axis.text.x = element_text(angle = 45,vjust = 0.5),
        legend.key.size = unit(4, "mm"))


# Plot 2 - number of citations
#++++++++++++++++++++++++++++++

dat.combined$Cited.by = as.numeric(dat.combined$Cited.by) # transform to a numeric variable
dat.Year.Citations = dat.combined %>% group_by(Word, Year) %>% summarise(count = sum(Cited.by, na.rm = TRUE))

dat.Year.Citations2 = dat.Year.Citations %>% group_by(Word) %>% mutate(CS = cumsum(count))

dat.Year.Words3 = data.frame(Year = rep("", length(unique(dat.Year.Citations2$Word))), 
                             count = rep("", length(unique(dat.Year.Citations2$Word))), 
                             Word = rep("", length(unique(dat.Year.Citations2$Word))))

dat.Year.Words3$Year = rep(2015, length(unique(dat.Year.Citations2$Word)))
dat.Year.Words3$count = dat.Year.Citations2$CS[which(dat.Year.Citations2$Year == "2015")]
dat.Year.Words3$Word = unique(dat.Year.Citations2$Word)

plot_pub_cit_year = ggplot(dat.Year.Citations2, aes(Year, CS)) + 
  geom_text_repel(aes(x = Year, 
                      y = count, 
                      label = Word, 
                      colour = Word), 
                  data = dat.Year.Words3,
                  size = 2.75, 
                  fontface = 'bold',
                  box.padding = unit(0.5, 'lines'),
                  point.padding = unit(1.6, 'lines'),
                  segment.color = '#555555',
                  arrow = arrow(length = unit(0.01, 'npc')))+
  geom_line(aes(color = Word)) + 
  geom_point(aes(color = Word)) + 
  theme_bw()+
  scale_x_continuous(breaks = c(1999:2015), labels = as.character(1999:2015))+
  labs(x = "", y = "Cumulative number of citations", colour = "Search Keywords")+
  # coord_cartesian(xlim = c(1999, 2017)) +
  theme(legend.title = element_text(size = 10), 
        axis.title.y = element_text(size = 10),
        legend.text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(size = 6),
        axis.text.x = element_text(angle = 45,vjust = 0.5),
        legend.key.size = unit(4, "mm"))

# Plot 3 - Distribution of the number of citations 
#++++++++++++++++++++++++++++++++++++++++++++++++++

dat.combined2 = dat.combined[-which(is.na(dat.combined$Cited.by)),]

dat.combined3 = filter(dat.combined2, Cited.by>200)

# without facets
ggplot(dat.combined2, aes(x=Cited.by))  + 
  geom_histogram(aes(y = ..density..), colour="#535353", fill="#1B9E77", binwidth=2, alpha = 0.6) +
  geom_density(alpha=.2, fill="#FF6666", lwd = 1, lty = "dashed", colour = "#D95F02")+
  xlab("Number of citations") + ylab("Number of publications")  + 
  theme_bw()+
  coord_cartesian(xlim = c(1, 200))+
  theme(axis.title = element_text(size = 10),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(size = 8))

# with facets 
ggplot(dat.combined2[which(dat.combined2$Year > 2010), ], aes(x=Cited.by))  + 
  geom_histogram(aes(y = ..density..), colour="#535353", fill="#1B9E77", binwidth=2, alpha = 0.6) +
  geom_density(alpha=.2, fill="#FF6666", lwd = 1, lty = "dashed", colour = "#D95F02")+
  xlab("Number of citations") + ylab("Number of publications")  + 
  theme_bw()+
  coord_cartesian(xlim = c(1, 100))+
  theme(axis.title = element_text(size = 10),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(size = 8))+
  facet_grid(Year~.)

# Plot of documents and citations by country
#++++++++++++++++++++++++++++++++++++++++++++

dat.combined.Country = read.csv(paste0("dataIn/Country/", words$Key2[1],"_Country.csv"), stringsAsFactors = FALSE, skip = 7)
dat.combined.Country$Word = words$Key[1]

for (i in 2:length(words$Key)){
  print(i)
  dat = read.csv(paste0("dataIn/Country/", words$Key2[i],"_Country.csv"), stringsAsFactors = FALSE, skip = 7)
  dat$Word = words$Key[i]
  
  dat.combined.Country = rbind(dat.combined.Country, dat)
}

names(dat.combined.Country) = c("Country", "Articles", "Word")

# writing the file 
write.csv(dat.combined.Country, "dataOut/data_Combined_Country.csv")

# Plot 2 by 2
#--------------

for (i in seq(1, length(words$Key), by = 2)){
print(i)
  
# first
dat.wd1 = dat.combined.Country[which(dat.combined.Country$Word == words$Key[i]),]
dat.wd1 = dat.wd1[order(dat.wd1$Articles, decreasing = TRUE), ]

dat.wd1$Country = factor(dat.wd1$Country, levels = dat.wd1$Country[order(dat.wd1$Articles, decreasing = FALSE)])
  
plot.Country.wd1 = ggplot(data = dat.wd1[1:10,])+
  geom_bar(aes(x = Country, y = Articles, fill = Country), stat = "identity", colour = "#777777", width = 0.5)+ 
  scale_fill_brewer(palette = "Spectral")+
  geom_text(aes(x = Country, y = Articles, label = as.character(Articles)), 
            hjust = -0.5, color = "#444444", size = 3, fontface = "bold")+
  coord_flip(ylim = c(0, max(dat.wd1$Articles)+50))+
  theme_bw()+
  ggtitle(paste0('Documents by country for "', words$Key[i], '" keyword'))+
  labs(x = "", y = "Number of articles")+
  theme(legend.position = "none", 
        title = element_text(size = 10))

# second
dat.wd2 = dat.combined.Country[which(dat.combined.Country$Word == words$Key[i+1]),]
dat.wd2 = dat.wd2[order(dat.wd2$Articles, decreasing = TRUE), ]

dat.wd2$Country = factor(dat.wd2$Country, levels = dat.wd2$Country[order(dat.wd2$Articles, decreasing = FALSE)])

plot.Country.wd2 = ggplot(data = dat.wd2[1:10,])+
  geom_bar(aes(x = Country, y = Articles, fill = Country), stat = "identity", colour = "#777777", width = 0.5)+ 
  scale_fill_brewer(palette = "Spectral")+
  geom_text(aes(x = Country, y = Articles, label = as.character(Articles)), 
            hjust = -0.5, color = "#444444", size = 3, fontface = "bold")+
  coord_flip(ylim = c(0, max(dat.wd2$Articles)+50))+
  theme_bw()+
  ggtitle(paste0('Documents by country for "', words$Key[i+1], '" keyword'))+
  labs(x = "", y = "Number of articles")+
  theme(legend.position = "none", 
        title = element_text(size = 10))

multiplot(plot.Country.wd1, plot.Country.wd2, cols = 1)

}


# Collaboration network
#==============================

library(bibliometrix)# use a bibliography package 


DDBS = readLines("dataIn/DDBS/DanubeDelta_BlackSea.bib")

DDBS.df <- convert2df(DDBS, dbsource = "scopus", format = "bibtex")# transform to dataframe 

# AU	Authors
# TI	Document Title
# SO	Publication Name (or Source)
# JI	ISO Source Abbreviation
# DT	Document Type
# DE	Authors' Keywords
# ID	Keywords associated by SCOPUS or ISI database
# AB	Abstract
# C1	Author Address
# RP	Reprint Address
# CR	Cited References
# TC	Times Cited
# PY	Year
# SC	Subject Category
# UT	Unique Article Identifier
# DB	Bibliographic Database

write.csv(DDBS.df, "dataOut/DDBS.csv")

# Bibliometric analysis
#------------------------
DDBS.results <- biblioAnalysis(DDBS.df, sep = ";")

DDBS.S = summary(object = DDBS.results, k = 10, pause = FALSE)

# plot(x = DDBS.results, k = 10, pause = FALSE)

# Some plots 
#--------------
#--------------

# Articles per year and average citations per article 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++

DDBS.df2 = DDBS.df %>% mutate(MA = unlist(lapply(DDBS.df$AU, function(x){
                                  l = str_split(x, ";")
                                  length(l[[1]])
                                })),
                                MAT = ifelse(MA>1,"M","S"))

DDBS.df.apy = DDBS.df2 %>% group_by(PY) %>% summarise(count = n())
DDBS.df.apy$MAT = "T"
names(DDBS.df.apy) = c("Year", "NArt", "MAT")
DDBS.df.apy = as.data.frame(DDBS.df.apy)

DDBS.df.mapy = DDBS.df2 %>% group_by(PY, MAT) %>% summarise(count = n()) %>% filter(MAT == "M") # multiple authored articles per year
DDBS.df.mapy = DDBS.df.mapy[,c(1,3,2)]
names(DDBS.df.mapy) = c("Year", "NArt", "MAT")
DDBS.df.mapy = as.data.frame(DDBS.df.mapy)

DDBS.df.AY = rbind(DDBS.df.apy, DDBS.df.mapy)


ggplot(DDBS.df.AY, aes(colour = MAT))+ 
  geom_point(aes(x = Year, y = NArt, group = 1), data = DDBS.df.AY[which(DDBS.df.AY$MAT == "T"),]) + 
  geom_line(aes(x = Year, y = NArt, group = 1), data = DDBS.df.AY[which(DDBS.df.AY$MAT == "T"),], linetype = 2) + 
  
  geom_point(aes(x = Year, y = NArt, group = 1), data = DDBS.df.AY[which(DDBS.df.AY$MAT == "M"),]) + 
  geom_line(aes(x = Year, y = NArt, group = 1), data = DDBS.df.AY[which(DDBS.df.AY$MAT == "M"),], linetype = 2) + 
  
  scale_color_discrete(breaks = c("T", "M"), labels = c("Total Articles", "Multi-Authored Articles"))+
  theme_bw()+
  labs(x = "", y = "Number of articles", colour = "")+
  theme(legend.title = element_text(size = 10), 
        axis.title.y = element_text(size = 10),
        legend.text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(size = 6),
        axis.text.x = element_text(angle = 45,vjust = 0.5),
        legend.key.size = unit(4, "mm"))

# DDBS.df.cpy = DDBS.df2 %>% group_by(PY) %>% summarise(count = n(), cited = sum(as.numeric(TC), na.rm = TRUE))

# 10 Most productive countries
#++++++++++++++++++++++++++++++++

# Data preparation 
source("functions/CapitalizeWord.R")

DDBS.df.ca = DDBS.S$MostProdCountries
names(DDBS.df.ca) = c("Country", "Articles", "Freq")
DDBS.df.ca$Articles = as.numeric(DDBS.df.ca$Articles)
DDBS.df.ca$Country = as.character(DDBS.df.ca$Country)
DDBS.df.ca$Country = str_replace_all(DDBS.df.ca$Country, "\\s+$", "") # remove all trailing space from the end 

DDBS.df.ca$Country = tolower(DDBS.df.ca$Country)
DDBS.df.ca$Country = sapply(DDBS.df.ca$Country, CapitalizeWord)
DDBS.df.ca$Country[which(DDBS.df.ca$Country == "Usa")] = "United States"
  
DDBS.df.ca$Country = factor(DDBS.df.ca$Country, levels = DDBS.df.ca$Country[order(DDBS.df.ca$Articles, decreasing = FALSE)])



DDBS.df.ctc = DDBS.S$TCperCountries
names(DDBS.df.ctc) = c("Country", "Total.Citations", "AAC")
DDBS.df.ctc$Total.Citations = as.numeric(DDBS.df.ctc$Total.Citations)
DDBS.df.ctc$Country = as.character(DDBS.df.ctc$Country)
DDBS.df.ctc$Country = str_replace_all(DDBS.df.ctc$Country, "\\s+$", "") # remove all trailing space from the end

DDBS.df.ctc$Country = tolower(DDBS.df.ctc$Country)
DDBS.df.ctc$Country = sapply(DDBS.df.ctc$Country, CapitalizeWord)
DDBS.df.ctc$Country[which(DDBS.df.ctc$Country == "Usa")] = "United States"

DDBS.df.ctc$Country = factor(DDBS.df.ctc$Country, levels = DDBS.df.ctc$Country[order(DDBS.df.ctc$Total.Citations, decreasing = FALSE)])


# Plots 

plot.Country.CA = ggplot(data = DDBS.df.ca)+
  geom_bar(aes(x = Country, y = Articles, fill = Country), stat = "identity", colour = "#777777", width = 0.5)+ 
  scale_fill_brewer(palette = "Spectral")+
  geom_text(aes(x = Country, y = Articles, label = as.character(Articles)), 
            hjust = -0.5, color = "#444444", size = 3, fontface = "bold")+
  coord_flip(ylim = c(0, max(DDBS.df.ca$Articles)+20))+
  theme_bw()+
  ggtitle(paste0('Documents by country for "', "Danube Delta or Black Sea", '" keywords'))+
  labs(x = "", y = "Number of articles")+
  theme(legend.position = "none", 
        title = element_text(size = 10))

plot.Country.CTC = ggplot(data = DDBS.df.ctc)+
  geom_bar(aes(x = Country, y = Total.Citations, fill = Country), stat = "identity", colour = "#777777", width = 0.5)+ 
  scale_fill_brewer(palette = "Spectral")+
  geom_text(aes(x = Country, y = Total.Citations, label = as.character(Total.Citations)), 
            hjust = -0.5, color = "#444444", size = 3, fontface = "bold")+
  coord_flip(ylim = c(0, max(DDBS.df.ctc$Total.Citations)+20))+
  theme_bw()+
  ggtitle(paste0('Documents by country for "', "Danube Delta or Black Sea", '" keywords'))+
  labs(x = "", y = "Number of citations")+
  theme(legend.position = "none", 
        title = element_text(size = 10))

multiplot(plot.Country.CA, plot.Country.CTC, cols = 1)

# Country scientific collaboration
#---------------------------------
library(igraph)

DDBS.df3 <- metaTagExtraction(DDBS.df, Field = "AU_CO", sep = ";")

NetMatrix <- biblioNetwork(DDBS.df3, analysis = "collaboration", network = "countries", sep = ";")

# define functions from package Matrix
diag <- Matrix::diag 
colSums <-Matrix::colSums

# delete not linked vertices
ind <- which(Matrix::colSums(NetMatrix)-Matrix::diag(NetMatrix)>0)
NET <- NetMatrix[ind,ind]

# Select number of vertices to plot
n <- 10    # n. of vertices
NetDegree <- sort(diag(NET),decreasing=TRUE)[n]
NET <- NET[diag(NET)>=NetDegree,diag(NET)>=NetDegree]

# delete diagonal elements (self-loops)
# diag(NET) <- 0
# NET[which(rownames(NET) != "ROMANIA"), which(colnames(NET) != "ROMANIA")] = 0

# Create igraph object
bsk.network <- graph.adjacency(NET, mode="undirected")

# Compute node degrees (#links) and use that to set node size:
deg <- degree(bsk.network, mode="out")
V(bsk.network)$size <- deg*0.05
E(bsk.network)$width <- deg*0.05


NET[which(rownames(NET) != "ROMANIA"), which(colnames(NET) != "ROMANIA")] = 0
bsk.network <- graph.adjacency(NET, mode="undirected")

# Remove loops
bsk.network <- simplify(bsk.network, remove.multiple = T, remove.loops = T) 

# Choose Network layout
l <- layout.circle(bsk.network)


## Plot the network
plot(bsk.network,layout = l, vertex.label.dist = c(-1,1.2), 
     vertex.size=deg*0.025,
     vertex.color="tomato",
     vertex.label.font = 2,
     vertex.frame.color = 'gray30', 
     vertex.label.color = 'black', 
     vertex.label = V(bsk.network)$name, 
     vertex.label.cex = 0.7,
     edge.width = deg*0.0025,
     edge.label = deg,
     edge.label.cex=0.7,
     # edge.color = "#999999", 
     main=paste0("Top ", n, " country collaborations"))


#++++++++++++++++++++++++++
#++++++++++++++++++++++++++
# ggnetwork 
#++++++++++++++++++++++++++
# Create igraph object
library(ggnetwork)
library(network)

NetMatrix <- biblioNetwork(DDBS.df3, analysis = "collaboration", network = "countries", sep = ";")

# delete not linked vertices
ind <- which(Matrix::colSums(NetMatrix)-Matrix::diag(NetMatrix)>0)

##-----------------------------
# ggnetwork 1 - All
#-----------------------------
NET1 <- NetMatrix[ind,ind]

# Select number of vertices to plot
n <- 7    # n. of vertices
NetDegree1 <- sort(diag(NET1),decreasing=TRUE)[n]
NET1 <- NET1[diag(NET1)>=NetDegree1,diag(NET1)>=NetDegree1]

# delete diagonal elements (self-loops)
# diag(NET) <- 0

# NET2[which(rownames(NET2) != "ROMANIA"), which(colnames(NET2) != "ROMANIA")] = 0

rownames(NET1) = tolower(rownames(NET1))
rownames(NET1) = sapply(as.list(rownames(NET1)), CapitalizeWord)

colnames(NET1) = tolower(colnames(NET1))
colnames(NET1) = sapply(as.list(colnames(NET1)), CapitalizeWord)

NET1 = as.matrix(NET1)
bsk.network1 <- network(NET1, directed=F)

NET1b = matrix(NET1, nrow = 1, byrow = TRUE)
NET1b = NET1b[matrix(lower.tri(NET1), nrow = 1, byrow = TRUE)]

e1 <- network.edgecount(bsk.network1)# number of edges 

# atre = NET2[which(rownames(NET2) == "Romania"),]
# atre = atre[-which(names(atre) == "Romania")]

set.edge.attribute(bsk.network1, "value", NET1b)
set.vertex.attribute(bsk.network1, "vsize", NET1b)

# network plot
ggplot(bsk.network1, aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(aes(size = value*0.02), color = "gray", linetype = 2) +
  geom_edgetext(aes(label = value), color = "DarkBlue", fill = "white", size = 3) +
  geom_nodes(aes(size = 2*vsize, colour = as.factor(vsize)), alpha = 0.4) +
  geom_nodes(aes(size = 0.5*vsize, colour = as.factor(vsize))) +
  geom_nodetext_repel(aes(label = vertex.names),
                      fontface = "bold", box.padding = unit(1, "lines"), size = 5) +
  scale_size_area("vsize", breaks = 1:3, max_size = 15)+
  theme_blank()+
  theme(legend.position = "none")

##-----------------------------
# ggnetwork 2 - Romania
#-----------------------------
NET2 <- NetMatrix[ind,ind]

# Select number of vertices to plot
n <- 10    # n. of vertices
NetDegree <- sort(diag(NET2),decreasing=TRUE)[n]
NET2 <- NET2[diag(NET2)>=NetDegree,diag(NET2)>=NetDegree]

# delete diagonal elements (self-loops)
# diag(NET) <- 0

NET2[which(rownames(NET2) != "ROMANIA"), which(colnames(NET2) != "ROMANIA")] = 0

rownames(NET2) = tolower(rownames(NET2))
rownames(NET2) = sapply(as.list(rownames(NET2)), CapitalizeWord)

colnames(NET2) = tolower(colnames(NET2))
colnames(NET2) = sapply(as.list(colnames(NET2)), CapitalizeWord)

NET2 = as.matrix(NET2)
bsk.network2 <- network(NET2, directed=F)

e <- network.edgecount(bsk.network2)# number of edges 
atre = NET2[which(rownames(NET2) == "Romania"),]
atre = atre[-which(names(atre) == "Romania")]

set.edge.attribute(bsk.network2, "value", atre)
set.vertex.attribute(bsk.network2, "vsize", atre)

# network plot
ggplot(bsk.network2, aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(aes(size = value*0.02), color = "gray", linetype = 2) +
  geom_edgetext_repel(aes(label = value), color = "grey25", fill = "white") +
  geom_nodes(aes(size = 2*vsize, colour = as.factor(vsize)), alpha = 0.4) +
  geom_nodes(aes(size = 0.5*vsize, colour = as.factor(vsize))) +
  geom_nodetext_repel(aes(label = vertex.names),
                       fontface = "bold", box.padding = unit(1, "lines")) +
  scale_size_area("vsize", breaks = 1:3, max_size = 25)+
  theme_blank()+
  theme(legend.position = "none")

# table
NET_tb = as.data.frame(NET2)
NET_tb$ID = rownames(NET2)
NET_tb = NET_tb[,c(11,1:10)]

NET_tb2 = NET_tb[, c(1,8)]
rownames(NET_tb2) = NULL

#------------------
# H-index graph 
#------------------

# hindex.DDBS = 
# DDBS.df$ID2 = 1:length(DDBS.df$AU)
DDBS.hindex = DDBS.df[, c("PY", "TC")]
DDBS.hindex$TC = as.numeric(DDBS.hindex$TC)
DDBS.hindex = DDBS.hindex[order(DDBS.hindex$TC, decreasing = TRUE), ]
DDBS.hindex$ID = 1:length(DDBS.hindex$TC)

# determine the h index

hindex.DDBS = max(which(DDBS.hindex$ID<=DDBS.hindex$TC))

# DDBS.hindex2 = DDBS.hindex[, c("ID", "TC")]

mval = max(DDBS.hindex$ID[which(DDBS.hindex$TC > 3)])

DDBS.hindex2 = DDBS.hindex[1:mval,]

df.text = data.frame(x = hindex.DDBS, y = hindex.DDBS, label = paste0("H-index = ", hindex.DDBS))

ggplot()+
  geom_area(aes(x = ID, y = ID), data = DDBS.hindex2, fill = "red", alpha = 0.3)+
  geom_line(aes(x = ID, y = ID), data = DDBS.hindex2, color = "red", alpha = 0.8, size = 1)+
  geom_area(aes(x = ID, y = TC), data = DDBS.hindex2, fill = "blue", alpha = 0.3)+
  geom_line(aes(x = ID, y = TC), data = DDBS.hindex2, color = "blue", alpha = 0.8, size = 1)+
  geom_point(data = df.text, aes(x = x, y = y), size = 4, color = "gold")+
  geom_text(data = df.text, aes(x = x, y = y+30, label = label), fontface = "bold")+
  theme_bw()+
  labs(x = "Number of documents", y = "Number of citations")+
  xlim(0,mval)
