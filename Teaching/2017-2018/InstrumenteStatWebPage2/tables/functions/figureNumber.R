fn = local({
  i = 0
  function(x) {
    i <<- i + 1
    paste('Figura ', i, ". ", x, sep = '')
  }
})