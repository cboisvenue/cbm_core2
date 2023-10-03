
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
    parameters = rbind(
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
        objectName = "pools",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      expectsInput(
        objectName = "flux",
        objectClass = "data.frame",
        desc = "",
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
        objectName = "pools_out",
        objectClass = "data.frame",
        desc = "",
        sourceURL = NA
      ),
      #createsOutput(
      #  objectName = "flux",
      #  objectClass = "data.frame",
      #  desc = "",
      #  sourceURL = NA
      #),
      #createsOutput(
      #  objectName = "parameters",
      #  objectClass = "data.frame",
      #  desc = "",
      #  sourceURL = NA
      #),
      #createsOutput(
      #  objectName = "state",
      #  objectClass = "data.frame",
      #  desc = "",
      #  sourceURL = NA
      #)
    )
  )
)

doEvent.cbm_exn_step <- function(sim, eventTime, eventType, debug = TRUE) {
  switch(
    eventType,
    init = {
      # TODO this is likely not the correct way to structure 
      # the event, need to clarify this
      step(sim)
    }
  )
  return(invisible(sim))
}

step <- function(sim) {
  box::use(reticulate[dict])
  box::use(libcbmr)

  cbm_exn_parameters <- dict(
    slow_mixing_rate = sim$slow_mixing_rate,
    turnover_parameters = sim$turnover_parameters,
    species = sim$species,
    root_parameters = sim$root_parameters,
    decay_parameters = sim$decay_parameters,
    disturbance_matrix_value = sim$disturbance_matrix_value,
    disturbance_matrix_association = sim$disturbance_matrix_association
  )
  cbm_vars <- libcbmr::cbm_exn_step(
    dict(
      pools = sim$pools,
      flux = sim$flux,
      parameters = sim$parameters,
      state = sim$state
    ),
    cbm_exn_parameters
  )
  sim$pools_out <- cbm_vars$pools
  #sim$flux <- cbm_vars$flux
#  sim$parameters <- cbm_vars$parameters
#  sim$state <- cbm_vars$state
  return(invisible(sim))
}