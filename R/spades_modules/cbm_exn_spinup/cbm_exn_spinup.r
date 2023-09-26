#box::use(
#  SpaDES.core[
#    defineParameter,
#    defineModule,
#    bindrows,
#    expectsInput,
#    createsOutput,
#    inputObjects,
#  ]
#)
box::use(reticulate[dict])
box::use(spinup_module = ../../libcbm/cbm_exn/cbm_exn_spinup)

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
    version = list(cbm_exn_spinup = "0.0.1"),
    spatialExtent = raster::extent(rep(NA_real_, 4)),
    timeframe = as.POSIXlt(c(NA, NA)),
    timeunit = "year",
    citation = list("citation.bib"),
    documentation = list("README.md"),
    reqdPkgs = list(
      "PredictiveEcology/reproducible@development (>= 2.0.8.9001)",
      "PredictiveEcology/SpaDES.core@useCache2 (>= 2.0.2.9003)",
      "PredictiveEcology/LandR@development"
    ),
    parameters = rbind(
      defineParameter(
        "spinup_debug_output_dir", "character", NULL, NA, NA,
        paste(
          "Optional directory. If defined spinup outputs will be written as",
          "CSV outputs to the specified directory",
          sep = ""
        )
      ),
      defineParameter("slow_mixing_rate", "data.frame", NULL, NA, NA, ""),
      defineParameter("turnover_parameters", "data.frame", NULL, NA, NA, ""),
      defineParameter("species", "data.frame", NULL, NA, NA, ""),
      defineParameter("root_parameters", "data.frame", NULL, NA, NA, ""),
      defineParameter("decay_parameters", "data.frame", NULL, NA, NA, ""),
      defineParameter(
        "disturbance_matrix_value", "data.frame", NULL, NA, NA, ""
      ),
      defineParameter(
        "disturbance_matrix_association", "data.frame", NULL, NA, NA, ""
      )
    ),
    inputObjects = bindrows(
      expectsInput(
        objectName = "spinup_parameters",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      expectsInput(
        objectName = "stand_increments",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      )
    ),
    outputObjects = bindrows(
      createsOutput(
        objectName = "pools",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      )
    )
  )
)

doEvent.cbm_exn_spinup <- function(sim, eventTime, eventType, debug = TRUE) {
  switch(
    eventType,
    init = {
      spinup(sim)
    }
  )
}

spinup <- function(sim) {

  print("hello??")
  
  cbm_exn_parameters <- dict(
    slow_mixing_rate = sim$slow_mixing_rate,
    turnover_parameters = sim$turnover_parameters,
    species = sim$species,
    root_parameters = sim$root_parameters,
    decay_parameters = sim$decay_parameters,
    disturbance_matrix_value = sim$disturbance_matrix_value,
    disturbance_matrix_association = sim$disturbance_matrix_association
  )
  cbm_vars <- spinup_module$spinup(
    dict(
        parameters = sim$spinup_parameters,
        increments = sim$stand_increments
      ),
    cbm_exn_parameters
  )
  sim$pools <- cbm_vars$pools
}