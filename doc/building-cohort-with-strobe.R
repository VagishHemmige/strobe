## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 10,
  fig.height = 8
)

## ----setup, message=FALSE, warning=FALSE, eval=requireNamespace("medicaldata", quietly = TRUE)----
library(strobe)
library(dplyr)

## ----basic_example, eval=requireNamespace("medicaldata", quietly = TRUE)------

#Obtain data
library(medicaldata)
data(cytomegalovirus)

#Create cohort
cytomegalovirus %>%
  strobe_initialize(inclusion_label = "Initial transplant cohort") %>%
  strobe_filter(
    condition = "age >= 30",
    inclusion_label = "Age ≥ 30",
    exclusion_reason = "Excluded: Age < 30"
  ) %>%
  strobe_filter(
    condition = "recipient.cmv == 1",
    inclusion_label = "CMV positive recipients",
    exclusion_reason = "Excluded: CMV negative"
  ) %>%
  strobe_filter(
    condition = "prior.transplant == 0",
    inclusion_label = "No prior transplant",
    exclusion_reason = "Excluded: Prior transplant"
  )%>%
  dplyr::select(age, recipient.cmv, donor.cmv, prior.transplant, sex, race)%>%
  #Show first rows and selected columns of final DF
  head()

## ----review_log, eval=requireNamespace("medicaldata", quietly = TRUE)---------
get_strobe_log()

## ----complex_example, eval=requireNamespace("medicaldata", quietly = TRUE)----
cytomegalovirus %>%
  strobe_initialize(inclusion_label = "All transplant recipients") %>%
  strobe_filter(
    condition = "age >= 18 & age <= 65",
    inclusion_label = "Age 18–65",
    exclusion_reason = "Excluded: Outside 18–65"
  ) %>%
  strobe_filter(
    condition = "recipient.cmv == 1",
    inclusion_label = "CMV positive",
    exclusion_reason = "Excluded: CMV negative"
  ) %>%
  strobe_filter(
    condition = "donor.cmv == 1",
    inclusion_label = "Donor CMV positive",
    exclusion_reason = "Excluded: Donor CMV negative"
  ) %>%
  strobe_filter(
    condition = "prior.transplant == 0",
    inclusion_label = "No prior transplant",
    exclusion_reason = "Excluded: Prior transplant"
  )%>%
  #Show first rows and selected columns of final DF
  dplyr::select(age, recipient.cmv, donor.cmv, prior.transplant, sex, race)%>%
  head()

## ----review_log_2, eval=requireNamespace("medicaldata", quietly = TRUE)-------
get_strobe_log()

