# Compute h-index
comp_hgindex = function(dat){
  dat_c = dat[, c("Cited.by", "Word")]
  dat_c$Cited.by = as.numeric(dat_c$Cited.by)
  dat_c = delete.na(dat_c)
  dat_c = dat_c[order(dat_c$Cited.by, decreasing = TRUE),]
  dat_c$ID = 1:length(dat_c$Cited.by)
  
  dat_c$square = dat_c$ID^2
  dat_c$cs = cumsum(dat_c$Cited.by)
  
  #h-index
  hindex <- max(which(dat_c$ID<=dat_c$Cited.by))
  
  #g-index
  gindex <- max(which(dat_c$square<dat_c$cs))
  
  c(hindex, gindex)
}