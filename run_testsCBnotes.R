## CB trying to figure out how to get the latest version of libcbm (2.6.0)
install.packages("reticulate")

###NOTE This is to install python - correct?
## from libcbmr README.md lines 68-76 ###########################
library(reticulate)
###NOTES this makes sure the path is set

condaVersion <- tryCatch(conda_version(conda = "auto"),
                         error = function(e) NA_character_)
if (is.na(condaVersion)) {
  reticulate::install_miniconda() ## full path cannot contain spaces!
  conda_create("r-reticulate")
}



###NOTES From Scott on Zulip
## This will tell you where the Rstudio session is finding Python.
## If using AChubaty's approach in libcbmr, it might be a different path "r-reticulate"
reticulate::import("sys")$executable

## or
#library(reticulate)
#reticulate::use_virtualenv("C:\\Users\\smorken\\dev\\python\\py311")
##NOTE mine would be "C:\\Users\\cboisven\\AppData\\Local\\R-MINI~1\\envs\\R-RETI~1\\python.exe"

###NOTES This gets the latest version of libcbm that Scott is maintaining
libcbm <- reticulate::import("libcbm")
print(reticulate::py_get_attr(libcbm, "__version__"))

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

result <- lapply(
  list.files(
    path = "tests", pattern = "test_", recursive = TRUE, full.names = TRUE
  ),
  testthat::test_file
)
