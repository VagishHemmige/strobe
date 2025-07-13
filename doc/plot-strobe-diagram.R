## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(strobe)
library(dplyr)
library(medicaldata)

data(cytomegalovirus)

cytomegalovirus_final_df<-cytomegalovirus %>%
  strobe_initialize("All transplant recipients") %>%
  strobe_filter("age >= 18 & age <= 65", "Age 18–65", "Excluded: Outside 18–65") %>%
  strobe_filter("recipient.cmv == 1", "CMV positive", "Excluded: CMV negative") %>%
  strobe_filter("donor.cmv == 1", "Donor CMV positive", "Excluded: Donor CMV negative") %>%
  strobe_filter("prior.transplant == 0", "No prior transplant", "Excluded: Prior transplant")

## -----------------------------------------------------------------------------
plot_strobe_diagram()

## -----------------------------------------------------------------------------
plot_strobe_diagram(incl_width_min = 4, incl_height = 1.2)

## -----------------------------------------------------------------------------
plot_strobe_diagram(lock_width_min = TRUE, lock_height = TRUE)

## -----------------------------------------------------------------------------
plot_strobe_diagram(incl_fontsize = 16, excl_fontsize = 14)

## -----------------------------------------------------------------------------
plot_strobe_diagram(incl_fontsize = 20, excl_fontsize = 18)

## -----------------------------------------------------------------------------
plot_strobe_diagram(
  incl_width_min = 5,
  excl_width_min = 4,
  incl_height = 1.5,
  excl_height = 1.2,
  incl_fontsize = 18,
  excl_fontsize = 16,
  lock_width_min = TRUE,
  lock_height = TRUE
)

## -----------------------------------------------------------------------------
plot_strobe_diagram(export_file = "strobe_diagram.png")

## -----------------------------------------------------------------------------
plot_strobe_diagram(export_file = "strobe_diagram.svg")

## -----------------------------------------------------------------------------
plot_strobe_diagram(lock_width_min = TRUE)

## -----------------------------------------------------------------------------
plot_strobe_diagram(lock_height = TRUE)

## ----eval=FALSE---------------------------------------------------------------
# strobe_filter(
#   condition = "...",
#   inclusion_label = "Eligible recipients\nwith CMV+ donors",
#   exclusion_reason = "Excluded:\nCMV- donors"
# )

