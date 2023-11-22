test_that(
  "spinup basic integration test works with spades", {

    box::use(SpaDES.project)
    box::use(testthat[test_that, expect_equal])
    box::use(reticulate[reticulate_import = import])
    libcbm_resources <- reticulate_import("libcbm.resources")
    n_stands <- 2
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
    growth_increments <- NULL
    n_stands <- 2
    for (i in 0:(n_stands - 1)) {
      copied_increments <- data.frame(net_increments)
      copied_increments <- cbind(data.frame(row_idx = i), copied_increments)
      growth_increments <- rbind(
        growth_increments, copied_increments
      )
    }

    # dummy inventory for testing
    spinup_parameters <- data.frame(
      age = sample(0L:60L, n_stands, replace = TRUE),
      area = rep(1.0, n_stands),
      delay = rep(0L, n_stands),
      return_interval = rep(125L, n_stands),
      min_rotations = rep(10L, n_stands),
      max_rotations = rep(30L, n_stands),
      spatial_unit_id = rep(17L, n_stands), # Ontario/Mixedwood plains
      sw_hw = rep(0L, n_stands),
      species = rep(20L, n_stands), # red pine
      mean_annual_temperature = rep(2.55, n_stands),
      historical_disturbance_type = rep(1L, n_stands),
      last_pass_disturbance_type = rep(1L, n_stands)
    )

    spinup_ops <- libcbmr::cbm_exn_spinup_ops(
      dict(
        parameters = spinup_parameters,
        increments = growth_increments
      ),
      libcbmr::cbm_exn_get_default_parameters()
    )

    spinup_op_sequence <- libcbmr::cbm_exn_get_spinup_op_sequence()
    out <- SpaDES.project::setupProject(
      name = "cbm_exn_spinup_integration_test",
      paths = list(
        modulePath = file.path(
          getwd(), "..", "..", "R"
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
      modules = "cbm_exn_spinup",
      times = list(start = 1998, end = 2000),
      packages = "PredictiveEcology/SpaDES.core@development (>= 2.0.2.9005)",

      spinup_parameters = spinup_parameters,
      growth_increments = growth_increments,
      spinup_ops = spinup_ops,
      spinup_op_sequence = spinup_op_sequence,
      parameters = libcbmr::cbm_exn_get_default_parameters(),
      require = "PredictiveEcology/SpaDES.core@development",
    )

    result <- do.call(simInitAndSpades, out)
    testthat::expect_equal(nrow(result$pools), 2)
    print(result$pools)
  }
)
