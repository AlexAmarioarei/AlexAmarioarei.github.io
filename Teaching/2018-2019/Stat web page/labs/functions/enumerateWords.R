enumerateWords = function(words){
  lwd = length(words)
  
  if (lwd == 1){
    print(words)
  }else{
    paste0(paste0(words[1:(lwd-1)], collapse = ", "), " and ", words[lwd])
  }
}