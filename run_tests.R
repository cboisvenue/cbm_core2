result <- lapply(
  list.files(
    path = "tests", pattern = "spades_", recursive = TRUE, full.names = TRUE
  ),
  testthat::test_file
)