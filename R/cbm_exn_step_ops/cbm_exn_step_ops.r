
defineModule(
  sim,
  list(
    name = "cbm_exn_step_ops",
    description = paste(
      "A module that prepares the default Carbon flow matrices ",
      "for cbm_exn_spinup",
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
      "PredictiveEcology/SpaDES.core@development (>= 2.0.2.9005)"
    ),
    parameters = NULL,
    inputObjects = bindrows(
      expectsInput(
        objectName = "model_config",
        objectClass = "list",
        desc = (
          "definitions for pools/flux_indicators and other model parameters"
        ),
        sourceURL = NA
      ),
      expectsInput(
        objectName = "pools",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      expectsInput(
        objectName = "flux",
        objectClass = "data.frame",
        desc = "storage for carbon pool flux during the step.",
        sourceURL = NA
      ),
      expectsInput(
        objectName = "parameters",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      expectsInput(
        objectName = "state",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      )
    ),
    outputObjects = bindrows(
      createsOutput(
        objectName = "step_ops",
        objectClass = "list",
        desc = "list of structured Carbon flow matrices",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "step_dist_ops_sequence",
        objectClass = "data.frame",
        desc = paste(
          "Dataframe of flux at end of spinup process, ",
          "all values are set to zero initially",
          sep = ""
        ),
        sourceURL = NA
      )
    )
  )
)

doEvent.cbm_exn_step_ops <- function(
  sim, eventTime, eventType, debug = TRUE
) {
  switch(
    eventType,
    init = {
      sim <- prepare_ops(sim)
    }
  )
  return(invisible(sim))
}

prepare_ops <- function(sim) {
  box::use(reticulate[dict])
  box::use(libcbmr)

  sim$step_ops <- libcbmr::cbm_exn_step_ops(
    dict(
      pools = sim$pools,
      flux = sim$flux,
      parameters = sim$parameters,
      state = sim$state
    ),
    sim$model_config
  )
  sim$step_dist_ops_sequence <- (
    libcbmr::cbm_exn_get_step_disturbance_ops_sequence()
  )
  sim$step_ops_sequence <- libcbmr::cbm_exn_get_step_ops_sequence()

  return(invisible(sim))
}