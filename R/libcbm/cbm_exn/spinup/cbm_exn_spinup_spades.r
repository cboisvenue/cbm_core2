box::use(SpaDES.core[defineParameter, defineModule, bindrows])


defineModule(
  sim,
  list(
    name = "cbm_exn_spinup",
    description = paste(
      "A module that runs CBM-CFS3 spinup routine ",
      "based on net increments",
      sep = ""
    ),
    keywords = NA,
    authors = person("", email = "", role = c("aut", "cre")),
    childModules = character(0),
    version = list(CBM_core = "0.0.1"),
    spatialExtent = raster::extent(rep(NA_real_, 4)),
    timeframe = as.POSIXlt(c(NA, NA)),
    timeunit = "year",
    citation = list("citation.bib"),
    documentation = list("README.txt", "CBM_core.Rmd"),
    reqdPkgs = list(
      "reticulate",
      "PredictiveEcology/reproducible@development (>= 2.0.8.9001)",
      "PredictiveEcology/SpaDES.core@useCache2 (>= 2.0.2.9003)",
      "PredictiveEcology/LandR@development"
    ),
    parameters = rbind(
      defineParameter(
        "spinup_debug_output_dir", "character", NULL, NA, NA,
        paste(
          "if defined spinup outputs will be written as",
          "CSV outputs to the specified dir",
          sep = ""
        )
      )
    ),
    inputObjects = bindrows(
      expectsInput(
        
      )
    )
  ),


)