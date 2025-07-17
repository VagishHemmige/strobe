test_that("create_terminal_branch works with unquoted and quoted variable names", {
  skip_if_not_installed("medicaldata")

  cytomegalovirus<- medicaldata::cytomegalovirus

  df <- cytomegalovirus

  df <- strobe_initialize(df, "Initial CMV transplant cohort")
  df <- strobe_filter(df, "age >= 30", "Age ≥ 30", "Excluded: Age < 30")
  df <- strobe_filter(df, "recipient.cmv == 1", "Recipient CMV positive", "Excluded: CMV negative")

  # Use unquoted
  df_unquoted <- create_terminal_branch(df, cgvhd)
  log_unquoted <- get_strobe_log()

  expect_equal(nrow(log_unquoted), 5)
  expect_equal(log_unquoted$inclusion_label[4], "cgvhd: 0")
  expect_equal(log_unquoted$inclusion_label[5], "cgvhd: 1")

  # Reset and use quoted
  df <- cytomegalovirus
  df <- strobe_initialize(df, "Initial CMV transplant cohort")
  df <- strobe_filter(df, "age >= 30", "Age ≥ 30", "Excluded: Age < 30")
  df <- strobe_filter(df, "recipient.cmv == 1", "Recipient CMV positive", "Excluded: CMV negative")

  df_quoted <- create_terminal_branch(df, "cgvhd")
  log_quoted <- get_strobe_log()

  expect_equal(nrow(log_quoted), 5)
  expect_equal(log_quoted$inclusion_label[4], "cgvhd: 0")
  expect_equal(log_quoted$inclusion_label[5], "cgvhd: 1")
})

test_that("create_terminal_branch throws error if levels exceed maximum", {
  skip_if_not_installed("medicaldata")

  cytomegalovirus<- medicaldata::cytomegalovirus

  df <- cytomegalovirus
  df <- strobe_initialize(df, "Initial CMV transplant cohort")
  df <- strobe_filter(df, "age >= 30", "Age ≥ 30", "Excluded: Age < 30")

  expect_error(
    create_terminal_branch(df, diagnosis),
    regexp = "has \\d+ levels.*Maximum allowed"
  )
})
