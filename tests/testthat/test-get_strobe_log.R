# Test for get_strobe_log()

test_that("get_strobe_log returns the correct log after filtering", {
  skip_if_not_installed("medicaldata")

  library(medicaldata)
  data(cytomegalovirus)

  df <- cytomegalovirus

  # Initialize STROBE tracking
  df <- strobe_initialize(df, inclusion_label = "All transplant recipients")

  # Apply a single filter
  df <- strobe_filter(
    df,
    condition = "age >= 18",
    inclusion_label = "Age 18+",
    exclusion_reason = "Excluded: Age < 18"
  )

  # Retrieve the STROBE log
  log <- get_strobe_log()

  # Check structure of the log
  expect_s3_class(log, "tbl_df")
  expect_named(log, c("id", "parent", "inclusion_label", "exclusion_reason", "filter", "remaining", "dropped"))

  # Expect two rows: start and one filter
  expect_equal(nrow(log), 2)

  # First row should be "start" with NA filter and dropped
  expect_equal(log$id[1], "start")
  expect_true(is.na(log$filter[1]))
  expect_true(is.na(log$dropped[1]))

  # Second row should reflect applied filter
  expect_equal(log$filter[2], "age >= 18")
  expect_equal(log$inclusion_label[2], "Age 18+")
})
