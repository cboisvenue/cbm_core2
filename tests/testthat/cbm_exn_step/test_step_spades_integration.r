test_that(
  "step basic integration test works with spades", {

    box::use(SpaDES.project)
    box::use(testthat[test_that, expect_equal])
    box::use(reticulate[reticulate_import = import])

    json <- reticulate_import("json")
    cbm_exn_variables <- reticulate_import(
      "libcbm.model.cbm_exn.cbm_exn_variables"
    )
    libcbm_resources <- reticulate_import("libcbm.resources")
    backends <- reticulate_import("libcbm.storage.backends")

    param_path <- libcbm_resources$get_cbm_exn_parameters_dir()
    pools <- json$loads(
      paste(readLines(file.path(param_path, "pools.json")), collapse = " ")
    )
    flux_config <- json$loads(
      paste(readLines(file.path(param_path, "flux.json")), collapse = " ")
    )
    flux_names <- lapply(flux_config, function(x) x["name"])
    n_stands <- 2L

    cbm_vars <- cbm_exn_variables$init_cbm_vars(
      n_stands, pools, flux_names, backends$BackendType$pandas
    )

    # convert to the dict[str: pd.DataFrame] format expected by cbm_exn
    # step by default
    cbm_vars <- cbm_vars$to_pandas()
    # set some reasonable values
    cbm_vars$pools[, ] <- 1.0
    cbm_vars$flux[, ] <- 0.0

    cbm_vars$parameters[, "mean_annual_temperature"] <- -1.0
    cbm_vars$parameters[, "disturbance_type"] <- 0L
    cbm_vars$parameters[, "merch_inc"] <- 0.1
    cbm_vars$parameters[, "foliage_inc"] <- 0.01
    cbm_vars$parameters[, "other_inc"] <- 0.05

    cbm_vars$state[, "area"] <- 1.0
    cbm_vars$state[, "spatial_unit_id"] <- 3L
    cbm_vars$state[, "land_class_id"] <- 0L
    cbm_vars$state[, "age"] <- 100L
    cbm_vars$state[, "species"] <- 6L
    cbm_vars$state[, "sw_hw"] <- 0L
    cbm_vars$state[, "time_since_last_disturbance"] <- 0L
    cbm_vars$state[, "time_since_land_use_change"] <- 0L
    cbm_vars$state[, "last_disturbance_type"] <- 0L
    cbm_vars$state[, "enabled"] <- 1L

    out <- SpaDES.project::setupProject(
      name = "cbm_exn_step_integration_test",
      paths = list(
        modulePath = file.path(
          getwd(), "..", "..", "..", "R"
        )
      ),
      options = list(
        repos = c(
          ## latest PredictievEcology packages
          PE = "https://predictiveecology.r-universe.dev/",
          ## latest sf and other spatial packages
          SF = "https://r-spatial.r-universe.dev/",
          CRAN = "https://cloud.r-project.org"
        ),
        reproducible.destinationPath = "inputs", ## TODO: SpaDES.project#24
        ## These are for speed
        reproducible.useMemoise = TRUE,
        # Require.offlineMode = TRUE,
        spades.moduleCodeChecks = FALSE
      ),
      modules = "cbm_exn_step",
      times = list(start = 1998, end = 2000),
      packages = "PredictiveEcology/SpaDES.core@development (>= 2.0.2.9005)",

      pools = cbm_vars$pools,
      flux = cbm_vars$flux,
      state = cbm_vars$state,
      parameters = cbm_vars$parameters,
      require = "PredictiveEcology/SpaDES.core@development",
      # add the defualt parameters for integration testing purposes
      slow_mixing_rate = read.csv(
        file.path(param_path, "slow_mixing_rate.csv")
      ),
      turnover_parameters = read.csv(
        file.path(param_path, "turnover_parameters.csv")
      ),
      species = read.csv(
        file.path(param_path, "species.csv")
      ),
      root_parameters = read.csv(
        file.path(param_path, "root_parameters.csv")
      ),
      decay_parameters = read.csv(
        file.path(param_path, "decay_parameters.csv")
      ),
      disturbance_matrix_value = read.csv(
        file.path(param_path, "disturbance_matrix_value.csv")
      ),
      disturbance_matrix_association = read.csv(
        file.path(param_path, "disturbance_matrix_association.csv")
      )
    )

    result <- do.call(simInitAndSpades, out)
    testthat::expect_equal(nrow(result$pools), 2)
  }
)
