
defineModule(
  sim,
  list(
    name = "cbm_exn_step",
    description = paste(
      "A module that runs CBM-CFS3 step routine ",
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
      "PredictiveEcology/SpaDES.core@development (>= 2.0.2.9005)"
    ),
    parameters = NULL,
    inputObjects = bindrows(
      expectsInput(
        objectName = "step_ops",
        objectClass = "list",
        desc = (
          "structured object containing pool flow matrices for the time step"
        ),
        sourceURL = NA
      ),
      expectsInput(
        objectName = "step_dist_ops_sequence",
        objectClass = "list",
        desc = paste(
          "list of names referencing `step_ops` defining the order of ",
          "operations to apply for disturbances in a timestep",
          sep = ""
        ),
        sourceURL = NA
      ),
      expectsInput(
        objectName = "step_ops_sequence",
        objectClass = "list",
        desc = paste(
          "list of names referencing `step_ops` to defining the order of ",
          "operations to apply for annual process dynamics in a timestep",
          sep = ""
        ),
        sourceURL = NA
      ),
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
        objectName = "pools",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "flux",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "parameters",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "state",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      )
    )
  )
)

doEvent.cbm_exn_step <- function(sim, eventTime, eventType, debug = TRUE) {
  switch(
    eventType,
    init = {
      # TODO this is likely not the correct way to structure 
      # the event, need to clarify this
      sim <- SpaDES.core::scheduleEvent(
        sim, start(sim), "cbm_exn_step", "step"
      )
    },
    step = {
      sim <- step(sim)
    }
  )
  return(invisible(sim))
}

step <- function(sim) {
  box::use(reticulate[dict])
  box::use(libcbmr)

  cbm_vars <- libcbmr::cbm_exn_step(
    dict(
      pools = sim$pools,
      flux = sim$flux,
      parameters = sim$parameters,
      state = sim$state
    ),
    sim$step_ops,
    sim$step_dist_ops_sequence,
    sim$step_ops_sequence,
    sim$model_config
  )
  sim$pools <- cbm_vars$pools
  sim$flux <- cbm_vars$flux
  sim$parameters <- cbm_vars$parameters
  sim$state <- cbm_vars$state
  return(invisible(sim))
}