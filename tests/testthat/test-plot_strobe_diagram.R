# Test for plot_strobe_diagram()

test_that("plot_strobe_diagram generates a graph object", {
  skip_if_not_installed("medicaldata")

  library(medicaldata)
  data(cytomegalovirus)

  # Build STROBE log
  cytomegalovirus %>%
    strobe_initialize("All transplant recipients") %>%
    strobe_filter("age >= 18", "Age 18+", "Excluded: Age < 18") %>%
    strobe_filter("recipient.cmv == 1", "CMV positive", "Excluded: CMV negative") %>%
    strobe_filter("prior.transplant == 0", "No prior transplant", "Excluded: Prior transplant")

  # Capture the plot output
  graph <- plot_strobe_diagram()

  # Check object class
  expect_s3_class(graph, "grViz")

  # Optional: Check that it contains expected nodes
  expect_true(grepl("CMV positive", graph$x$diagram))
  expect_true(grepl("Excluded: CMV negative", graph$x$diagram))
})
