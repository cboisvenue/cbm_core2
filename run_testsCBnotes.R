## CB trying to figure out how to get the latest version of libcbm (2.6.0)
install.packages("reticulate")


library(reticulate)

###NOTE: For Python installation see libcbmr repo (https://github.com/smorken/libcbmr)

###NOTES This will tell you where the Rstudio session is finding Python.
### If using approach in libcbmr, it might be a different path "r-reticulate"

#reticulate::import("sys")$executable

### Check what is the virtual environment being used
virtualenv_list()
#[1] "r-reticulate"
virtualenv_python()
#[1] "C:/Users/cboisven/Documents/.virtualenvs/r-reticulate/Scripts/python.exe"

### set your virutal environment to avoid confusion.
use_virtualenv("r-reticulate")

## or
#library(reticulate)
#reticulate::use_virtualenv("C:\\Users\\smorken\\dev\\python\\py311")
##NOTE mine would be "C:/Users/cboisven/Documents/.virtualenvs/r-reticulate/Scripts/python.exe""

###NOTES This gets the latest version of libcbm that Scott is maintaining
libcbm <- reticulate::import("libcbm")

###NOTES If you already had a version loaded you may have to do it this way
libcbm <- reticulate::py_install("libcbm", envname = "r-reticulate", ignore_installed=TRUE)

###NOTES Check what you have
#print(reticulate::py_get_attr(libcbm, "__version__"))

###NOTES This package is used in the testthat scripts Scott has
install.packages("box")
getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

# getOrUpdatePkg("Require", "0.3.1.14")
getOrUpdatePkg("SpaDES.project", "0.0.8.9026")

install.packages("devtools")
devtools::install_github("smorken/libcbmr")
library(libcbmr)
###NOTES Not sure why the raster package is still being used and why it is not
###getting loaded.
library(raster)

result <- lapply(
  list.files(
    path = "tests", pattern = "test_", recursive = TRUE, full.names = TRUE
  ),
  testthat::test_file
)
