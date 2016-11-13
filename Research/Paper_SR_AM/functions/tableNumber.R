tn = local({
  j = 0
  function(x) {
    j <<- j + 1
    paste('Table ', j, ": ", x, sep = '')
  }
})