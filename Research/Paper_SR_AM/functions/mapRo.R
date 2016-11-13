# # Loading packages
# #====================
# 
# library(tmap)
# library(readxl)
# library(tidyr)
# library(dplyr)
# library(stringr)
# library(stringi)
# 
# library(ggplot2)
# library(ggmap)
# library(ggrepel)
# library(network)
# library(sna)
# library(ggnetwork)
# library(GGally)

# Create the map
#====================
world = map_data("world")

romania = world[which(world$region == "Romania"),]

romaniaMap = ggplot(romania, aes(x = long, y = lat)) +
              geom_polygon(aes(group = group), color = "grey65",
                           fill = "#f9f9f9", size = 0.2)+
              theme_minimal()

# Create the network
#====================

DanubeD = read.csv("dataIn/DDBS/DanubeDelta_BlackSea.csv", encoding = "UTF-8" , stringsAsFactors = FALSE)

colnames(DanubeD)[1] = "Authors"

DanubeD.red = DanubeD[, c("Authors", "Title", "Year", "Cited.by", "Affiliations", "EID")] # keep only what we are interested in (that is Affils)

write.csv(DanubeD.red, "dataIn/DDBS/DDBS_data.csv")

# load function 
source("functions/transformScopus.R")

DanubeD1 = transformScopus("DDBS/DDBS_data.csv", "DDBS_data_tr.csv")

# remove observations without county

DanubeD1 = DanubeD1[which(DanubeD1$County != ""), ]

# add the latitude and longitude for each county

DanubeD1$long = rep(0, length(DanubeD1$County))
DanubeD1$lat = rep(0, length(DanubeD1$County))

datCoord = data.frame(County = unique(DanubeD1$County), 
                      long =  rep(0, length(unique(DanubeD1$County))), 
                      lat = rep(0, length(unique(DanubeD1$County))), stringsAsFactors = FALSE)

for (i in 1:length(datCoord$County)){
  coords = geocode(datCoord$County[i])
  
  datCoord$long[i] = coords[1]
  datCoord$lat[i] = coords[2]
  
  DanubeD1$long[which(DanubeD1$County == datCoord$County[i])] = coords[1]
  DanubeD1$lat[which(DanubeD1$County == datCoord$County[i])] = coords[2]
}

datCoord$long = unlist(datCoord$long)
datCoord$lat = unlist(datCoord$lat)

DanubeD1$long = unlist(DanubeD1$long)
DanubeD1$lat = unlist(DanubeD1$lat)

# a first plot 
#------------------------

romaniaMap + 
  geom_point(data = datCoord, aes(x = long, y = lat), color = "red", alpha = 0.5)+
  geom_text_repel(data = datCoord, aes(x = long, y = lat, label = County))


# Create the network
#------------------------

DanubeD1.red = DanubeD1[, c("EID", "County", "CountyCode", "lat", "long")]

nrAffils = DanubeD1.red %>% group_by(EID) %>% summarise(count = n())

CountyIn = ""
CountyOut = ""
EIDc = ""

for (i in 1:length(nrAffils$EID)){
  naffils = nrAffils$count[i]
  eid = nrAffils$EID[i]
  
  county = DanubeD1.red$County[which(DanubeD1.red$EID == eid)]
  uc = unique(county)
  suc = length(uc)
  
  if (suc == 1){
    
    CountyIn = c(CountyIn, uc)
    CountyOut = c(CountyOut, uc)
    EIDc = c(EIDc, eid)
    
  }else{
    
    cmb = combn(1:suc, 2, simplify = FALSE)
    lcmb = length(cmb)
    
    for (j in 1:lcmb){
      indx = cmb[[j]][1]
      indy = cmb[[j]][2]
      
      CountyIn = c(CountyIn, uc[indx])
      CountyOut = c(CountyOut, uc[indy])
      EIDc = c(EIDc, eid)
    }
  }
  
}

datNetRom = data.frame(EID = EIDc, CountyIn = CountyIn, CountyOut = CountyOut)
datNetRom = datNetRom[-1,] # remove the first row 

# convert to network
rownames(datCoord) <- datCoord$County

datNetRom = datNetRom[,-1] # delete the eid column
datNetRom = network(datNetRom, directed = TRUE)

# add geographic coordinates
datNetRom %v% "lat" <- datCoord[network.vertex.names(datNetRom), "lat" ]
datNetRom %v% "lon" <- datCoord[network.vertex.names(datNetRom), "long" ]

# drop isolated collaborations
# delete.vertices(datNetRom , which(degree(datNetRom) < 2))

# compute degree centrality
datNetRom %v% "degree" <- degree(datNetRom, gmode = "digraph")

# add size to datCoord
datCoord$Size = rep(0, length(datCoord$County))
datCoord[network.vertex.names(datNetRom), "Size"] = degree(datNetRom, gmode = "digraph")

# overlay network data to map
# NetCountyRom = ggnetworkmap(romaniaMap, datNetRom, size = 8, great.circles = TRUE,
#              # segment.color = "steelblue",
#              weight = degree, 
#              node.color = "tomato",
#              node.alpha = 0.5)+
#   geom_point(data = datCoord, aes(x = long, y = lat, size = Size), color = "blue", alpha = 0.3)+
#   geom_text_repel(data = datCoord, aes(x = long, y = lat, label = County))+
#   theme_minimal()+
#   theme(legend.position = "none")

NetCountyRom = ggnetworkmap(romaniaMap, datNetRom, size = 20, great.circles = TRUE,
                                         # segment.color = "tomato",
                                         weight = degree, 
                                         node.color = "tomato",
                                         node.alpha = 0.5)+
  geom_point(data = datCoord, aes(x = long, y = lat, size = 10*Size), color = "steelblue", alpha = 0.3)+
  geom_text_repel(data = datCoord, aes(x = long, y = lat, label = County))+
  theme_minimal()+
  theme(legend.position = "none")

# write files to csv
# write.csv(datCoord, "dataOut/datCoopCounties.csv")
