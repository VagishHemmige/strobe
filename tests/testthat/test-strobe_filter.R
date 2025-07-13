# Test for strobe_filter()

test_that("strobe_filter applies a filter and updates the STROBE log", {
  skip_if_not_installed("medicaldata")

  library(medicaldata)
  data(cytomegalovirus)

  df <- cytomegalovirus

  # Initialize STROBE tracking
  df <- strobe_initialize(df, inclusion_label = "All patients")

  # Apply first filter: age between 18 and 65
  filtered_df <- strobe_filter(
    data = df,
    condition = "age >= 18 & age <= 65",
    inclusion_label = "Age 18–65",
    exclusion_reason = "Excluded: Outside age range"
  )

  # Get the updated log
  log <- get_strobe_log()

  # It should now contain two rows: the initial and one filter
  expect_equal(nrow(log), 2)

  # Check that the second row has a valid ID like "step1"
  expect_match(log$id[2], "^step\\d+$")

  # Parent of step1 should be "start"
  expect_equal(log$parent[2], "start")

  # Inclusion and exclusion labels should be recorded correctly
  expect_equal(log$inclusion_label[2], "Age 18–65")
  expect_equal(log$exclusion_reason[2], "Excluded: Outside age range")

  # The filter string should match what was supplied
  expect_equal(log$filter[2], "age >= 18 & age <= 65")

  # Remaining count should match the filtered dataset
  expect_equal(log$remaining[2], nrow(filtered_df))

  # Dropped count should equal number excluded
  expect_equal(log$dropped[2], nrow(df) - nrow(filtered_df))
})
