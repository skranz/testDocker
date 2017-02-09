# install required R packages

library(methods)

path = .libPaths()[1]
glob.overwrite = TRUE
path = "/usr/local/lib/R/site-library"

success = failed = NULL

from.cran = function(pkg, lib = path, overwrite = glob.overwrite,...) {
  if (!overwrite) {
    if (require(pkg,character.only = TRUE)) {
      cat("\npackage ",pkg," already exists.")
      return()
    }
  }
  res = try(install.packages(pkg, lib=lib))
  if (require(pkg,character.only = TRUE)) {
    success <<- c(success,pkg)
  } else {
    failed <<- c(failed,pkg)
  }
}

from.github = function(pkg, lib = path, ref="master", overwrite = glob.overwrite,upgrade_dependencies = FALSE,...) {
  repo = pkg
  pkg = strsplit(pkg,"/",fixed=TRUE)[[1]]
  pkg = pkg[length(pkg)]

  if (!overwrite) {
    if (require(pkg,character.only = TRUE)) {
      cat("\npackage ",pkg," already exists.")
      return()
    }
  }

  library(devtools)
  res = try(
  with_libpaths(new = path,
    install_github(repo,ref = ref,upgrade_dependencies = upgrade_dependencies,...)
  ))
  if (require(pkg,character.only = TRUE)) {
    success <<- c(success,pkg)
  } else {
    failed <<- c(failed,pkg)
  }

}



cat("\n\nFailed installations:\n")
print(failed)

cat("\n\nSuccessfully installed:\n")
print(success)

txt = paste0(
  "Installation Time ", as.character(Sys.time()),
  "\n\nFailed installations:\n", paste0(failed, collapse=", "),
  "\n\nSuccessful installations:\n", paste0(success, collapse=", ")
)

try({
  writeLines(txt,"~/r-install.log")
  writeLines(txt,"/var/log/r-install.log")

})