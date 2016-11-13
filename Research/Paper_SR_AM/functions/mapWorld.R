# Tmap with world countries by number of research articles published 

data("World") # load world map data

World$name = as.character(World$name)

World$Articles = rep(0, length(World$name))

# dat_articles = read.csv("dataIn/All_Key.csv")
dat_articles_country = read.csv("dataIn/Country/All_Country.csv", skip = 7, stringsAsFactors = FALSE)
names(dat_articles_country) = c("Country", "NArt")

dat_articles_country$Country[which(dat_articles_country$Country == "Russian Federation")] = "Russia"
dat_articles_country$Country[which(dat_articles_country$Country == "Syrian Arab Republic")] = "Syria"
dat_articles_country$Country[which(dat_articles_country$Country == "Bosnia and Herzegovina")] = "Bosnia and Herz."
dat_articles_country$Country[which(dat_articles_country$Country == "Brunei Darussalam")] = "Brunei"
dat_articles_country$Country[which(dat_articles_country$Country == "Czech Republic")] = "Czech Rep."
dat_articles_country$Country[which(dat_articles_country$Country == "Dominican Republic")] = "Dominican Rep."
dat_articles_country$Country[which(dat_articles_country$Country == "Viet Nam")] = "Vietnam"

for (i in 1:length(dat_articles_country$Country)){
  ind = which(World$name == dat_articles_country$Country[i])
  World$Articles[ind] = dat_articles_country$NArt[i]
}

World$iso2 = paste0(World$name, "\n", as.character(World$Articles))
  
# world map 
tm.World = tm_shape(World)+
            tm_fill("Articles", palette = "Reds", title = "Number of articles", breaks = c(0,100,500,1000,3000,10000,20000, 35000))+
            tm_borders(alpha=.5)+
            tm_text("iso2", size="Articles", shadow = TRUE, legend.size.show = FALSE)+
            # tm_format_World()+
            tm_layout(legend.title.size = 1, 
                      legend.text.size = 0.7, 
                      frame = FALSE,
                      outer.margins = rep(0,4),
                      inner.margins = rep(0,4),
                      between.margin = 0)+
            tm_style_natural()

# Europe map 

data("Europe")

Europe$name = as.character(Europe$name)
Europe$Articles = rep(0, length(Europe$name))

for (i in 1:length(dat_articles_country$Country)){
  ind = which(Europe$name == dat_articles_country$Country[i])
  Europe$Articles[ind] = dat_articles_country$NArt[i]
}

Europe$iso2 = paste0(Europe$name, "\n", as.character(Europe$Articles))

tm.Europe = tm_shape(Europe)+
              tm_fill("Articles", palette = "Reds", title = "Number of articles", breaks = c(10, 100, 500, 1000, 2000, 3000, 5000, 10000, 15000))+
              tm_borders(alpha=.5)+
              tm_text("iso2", size=0.55, shadow = TRUE)+
              tm_format_World()+
              tm_layout(legend.title.size = 1, 
                        legend.text.size = 0.6,
                        legend.frame = TRUE,
                        legend.outside = FALSE,
                        legend.outside.size = 0.2,
                        legend.bg.color = "gray", 
                        legend.bg.alpha = 0.2,
                        legend.position = c("right", "top"),
                        frame = FALSE,
                        outer.margins = rep(0,4),
                        inner.margins = rep(0,4),
                        between.margin = 0,
                        bg.color = "lightskyblue1")