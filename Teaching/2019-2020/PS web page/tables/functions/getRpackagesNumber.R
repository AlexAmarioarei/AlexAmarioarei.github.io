# Scrapes CRAN archives to determine the number of packages per release

# Create a list of pages to scrape, including both archive and current
extract_url <- function(){
  url <- list(
    archive = "https://cran-archive.r-project.org/bin/windows/contrib/",
    active  = "https://cran.r-project.org/bin/windows/contrib/"
  )
  
  get_urls <- function(url){
    txt <- readLines(url)
    idx <- grep("\\d.\\d+/", txt)
    txt[idx]
    versions <- gsub(".*?>(\\d.\\d+(/)).*", "\\1", txt[idx])
    versions
    paste0(url, versions)
  }
  z <- lapply(url, get_urls)
  unname(unlist(z))
}


# Given a CRAN URL, extract the number of packages and date
extract_pkg_info <- function(url){
  extract_date <- function(txt, fun = max){
    txt <- txt[-grep("[(STATUS)|(PACKAGES)](.gz)*", txt)]
    pkgs <- grep(".zip", txt)
    txt <- txt[pkgs]
    ptn <- ".*(\\d{4}-\\d{2}-\\d{2}).*" # gsub( ".*(\\d{1,2}/\\d{1,2}/\\d{4}).*", "\\1", string)
    idx <- grep(ptn, txt)
    date <- gsub(ptn, "\\1", txt[idx])
    date <- as.Date(date, format = "%Y-%m-%d")
    match.fun(fun)(date)
  }
  
  message(url)
  txt <- readLines(url)
  count <- length(grep(".zip", txt))
  # sum(grepl(".zip", txt))
  
  # head(txt)
  data.frame(
    version = basename(url),
    date = extract_date(txt),
    pkgs = count
  )
}


# Get the list of CRAN URLs
CRAN_urls <- extract_url()
CRAN_urls

# Extract package information
pkgs <- lapply(CRAN_urls, extract_pkg_info)
pkgs <- do.call(rbind, pkgs)
head(pkgs)
tail(pkgs)

pkgs <- head(pkgs, -2) # Remove r-devel and r-future

write.csv(pkgs, "labs/dataOut/pkgsNr.csv", row.names = FALSE)

# Extract major release information
major_releases <- pkgs[grep("\\.0", pkgs$version), ]

#
library(ggplot2)
p <- ggplot(pkgs, aes(x = date, y = pkgs)) + 
  geom_smooth() +
  geom_point() + 
  geom_rug(colour = "grey50") +
  geom_vline(data = major_releases, 
             aes(xintercept = as.numeric(date)), 
             colour = "grey80") +
  geom_text(data = major_releases, 
            aes(label = paste("Version", version), y = 8000), 
            angle = 90, 
            colour = "red",
            hjust = 1, vjust = -1) +
  theme_minimal(16) +
  ggtitle("Number of CRAN packages per R version") +
  xlab(NULL) +
  ylab(NULL)

print(p)
