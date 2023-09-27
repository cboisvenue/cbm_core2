box::use(SpaDES.project)
box::use(testthat[test_that, expect_equal])
box::use(reticulate[reticulate_import = import])

libcbm_resources <- reticulate_import("libcbm.resources")

param_path <- libcbm_resources$get_cbm_exn_parameters_dir()

test_that(
  "spinup basic integration test works with spades", {
    get_test_net_increments <- function() {
      net_increments <- read.csv(
        file.path(
      libcbm_resources$get_test_resources_dir(),
      "cbm_exn_net_increments",
      "net_increments.csv"
    )
  )

  colnames(net_increments) <- c(
    "age", "merch_inc", "foliage_inc", "other_inc"
  )
  stand_increments <- NULL
  n_stands <- 2
  for (i in 0:(n_stands - 1)) {
    copied_increments <- data.frame(net_increments)
    copied_increments <- cbind(data.frame(row_idx = i), copied_increments)
    stand_increments <- rbind(
      stand_increments, copied_increments
    )
  }
  return(stand_increments)
}

get_test_spinup_parameters <- function(){
  n_stands <- 2
  spinup_parameters <- data.frame(
    age = sample(0L:60L, n_stands, replace = TRUE),
    area = rep(1.0, n_stands),
    delay = rep(0L, n_stands),
    return_interval = rep(125L, n_stands),
    min_rotations = rep(10L, n_stands),
    max_rotations = rep(30L, n_stands),
    spatial_unit_id = rep(17L, n_stands), # Ontario/Mixedwood plains
    species = rep(20L, n_stands), # red pine
    mean_annual_temperature = rep(2.55, n_stands),
    historical_disturbance_type = rep(1L, n_stands),
    last_pass_disturbance_type = rep(1L, n_stands)
      )
      return(spinup_parameters)
    }
    out <- SpaDES.project::setupProject(
      name = "cbm_exn_spinup_integration_test",
      paths = list(
        modulePath = file.path(
          getwd(), "..", "..", "..", "R", "spades_modules")
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
      modules = "cbm_exn_spinup",
      times = list(start = 1998, end = 2000),

      spinup_parameters = get_test_spinup_parameters(),
      stand_increments = get_test_net_increments(),
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

  }
)
