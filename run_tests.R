result <- lapply(
  list.files(
    path = "tests", pattern = "test_", recursive = TRUE, full.names = TRUE
  ),
  testthat::test_file
)