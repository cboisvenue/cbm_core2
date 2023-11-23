
defineModule(
  sim,
  list(
    name = "cbm_exn_spinup_ops",
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
        objectName = "model_config",
        objectClass = "list",
        desc = (
          "definitions for pools/flux_indicators and other model parameters"
        ),
        sourceURL = NA
      )
    ),
    outputObjects = bindrows(
      createsOutput(
        objectName = "spinup_ops",
        objectClass = "list",
        desc = "list of structured Carbon flow matrices",
        sourceURL = NA
      ),
      createsOutput(
        objectName = "spinup_op_sequence",
        objectClass = "data.frame",
        desc = paste(
          "list of operation names to apply for each spinup step referencing ",
          "`spinup_ops`",
          sep = ""
        ),
        sourceURL = NA
      )
    )
  )
)

doEvent.cbm_exn_spinup_ops <- function(
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

  sim$spinup_ops <- libcbmr::cbm_exn_spinup_ops(
    dict(
      parameters = sim$spinup_parameters,
      increments = sim$growth_increments
    ),
    sim$model_config
  )

  sim$spinup_op_sequence <- libcbmr::cbm_exn_get_spinup_op_sequence()

  return(invisible(sim))
}
