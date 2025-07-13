#test-strobe_initialize.R

# Test for strobe_initialize()

test_that("strobe_initialize sets up the initial STROBE log correctly", {
  # Skip test if the medicaldata package is not available
  skip_if_not_installed("medicaldata")

  # Load the dataset
  library(medicaldata)
  data(cytomegalovirus)

  df <- cytomegalovirus

  # Call strobe_initialize with a custom inclusion label
  out <- strobe_initialize(df, inclusion_label = "Initial cohort")

  # Check that the returned data is identical to the input
  expect_identical(out, df)

  # Retrieve the STROBE tracking log
  log <- get_strobe_log()

  # Ensure the log is a tibble
  expect_s3_class(log, "tbl_df")

  # It should contain only one row (the initialization)
  expect_equal(nrow(log), 1)

  # The ID of the first row should be "start"
  expect_equal(log$id[1], "start")

  # Parent should be NA for the initial row
  expect_true(is.na(log$parent[1]))

  # The inclusion label should match what we supplied
  expect_equal(log$inclusion_label[1], "Initial cohort")

  # There should be no exclusion reason or filter at this point
  expect_true(is.na(log$exclusion_reason[1]))
  expect_true(is.na(log$filter[1]))

  # Remaining should equal the number of rows in the input data
  expect_equal(log$remaining[1], nrow(df))

  # Dropped should be NA on initialization
  expect_true(is.na(log$dropped[1]))
})
