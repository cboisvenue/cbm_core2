
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
      "PredictiveEcology/SpaDES.core@development (>= 2.0.2.9005)"
    ),
    parameters = rbind(
      defineParameter(
        "spinup_debug_output_dir", "character", NULL, NA, NA,
        paste(
          "Optional directory. If defined spinup outputs will be written as",
          "CSV outputs to the specified directory",
          sep = ""
        )
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
        objectName = "growth_increments",
        objectClass = "data.frame",
        desc = paste(
          "This is a dataframe with columns",
          "row_idx, age, merch_inc, foliage_inc, ",
          "other_inc representing the age/increment ",
          "series for each defined simulation area",
          sep = ""
        ),
        sourceURL = NA
      ),
      expectsInput(
        objectName = "spinup_ops",
        objectClass = "list",
        desc = paste(
          "Structured object describing the Carbon flows for the spinup ",
          "operations",
          sep = ""
        ),
        sourceURL = NA
      ),
      expectsInput(
        objectName = "spinup_op_sequence",
        objectClass = "list",
        desc = paste(
          "list of op names, as defined in spinup_ops defining the order ",
          "in which operations are applied",
          sep = ""
        ),
        sourceURL = NA
      )
    ),
    outputObjects = bindrows(
      createsOutput(
        objectName = "pools",
        objectClass = "data.frame",
        desc = "Dataframe of pools at the end of the spinup process",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "flux",
        objectClass = "data.frame",
        desc = paste(
          "Dataframe of flux at end of spinup process, ",
          "all values are set to zero initially",
          sep = ""
        ),
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

doEvent.cbm_exn_spinup <- function(sim, eventTime, eventType, debug = TRUE) {
  switch(
    eventType,
    init = {
      spinup(sim)
    }
  )
  return(invisible(sim))
}

spinup <- function(sim) {
  box::use(reticulate[dict])
  box::use(libcbmr)

  cbm_vars <- libcbmr::cbm_exn_spinup(
    dict(
      parameters = sim$spinup_parameters,
      increments = sim$stand_increments
    ),
    sim$spinup_ops,
    sim$spinup_op_sequence,
    sim$parameters
  )
  sim$pools <- cbm_vars$pools
  sim$flux <- cbm_vars$flux
  sim$parameters <- cbm_vars$parameters
  sim$state <- cbm_vars$state
  return(invisible(sim))
}