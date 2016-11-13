require_library <- function(pkgname) {
  if (!require(pkgname, character.only = TRUE)) {
    install.packages(pkgname, dependencies = TRUE)
    library(pkgname)
  }
  require(pkgname)
}