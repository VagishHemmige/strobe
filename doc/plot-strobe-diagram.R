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

cytomegalovirus_df<-cytomegalovirus %>%
  strobe_initialize("All transplant recipients") %>%
  strobe_filter("age >= 18 & age <= 65", "Age 18–65", "Excluded: Outside 18–65") %>%
  strobe_filter("recipient.cmv == 1", "CMV positive", "Excluded: CMV negative") %>%
  strobe_filter("donor.cmv == 1", "Donor CMV positive", "Excluded: Donor CMV negative") %>%
  strobe_filter("prior.transplant == 0", "No prior transplant", "Excluded: Prior transplant")

## ----eval=FALSE---------------------------------------------------------------
# plot_strobe_diagram()

## ----out.width="50%", fig.align="center"--------------------------------------
getwd()
dir.exists("man/figures")  # Should return TRUE

svg_file_2_1 <-plot_strobe_diagram(export_file = "strobe-diagram_vignette2_1.svg")

knitr::include_graphics("strobe-diagram_vignette2_1.svg")


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_2a <-plot_strobe_diagram(incl_width_min = 10, excl_width_min = 10, 
                                   export_file = "strobe-diagram_vignette2_2a.svg")
knitr::include_graphics("strobe-diagram_vignette2_2a.svg")


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_2b <-plot_strobe_diagram(incl_height = 5, excl_height = 5, 
                                   export_file = "strobe-diagram_vignette2_2b.svg")
knitr::include_graphics("strobe-diagram_vignette2_2b.svg")


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_3 <-plot_strobe_diagram(lock_width_min = TRUE, 
                                   lock_height = TRUE, 
                                   export_file = "strobe-diagram_vignette2_3.svg")
knitr::include_graphics("strobe-diagram_vignette2_3.svg")


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_4 <-plot_strobe_diagram(incl_fontsize = 16, 
                                   excl_fontsize = 14, 
                                   export_file = "strobe-diagram_vignette2_4.svg")
knitr::include_graphics("strobe-diagram_vignette2_4.svg")


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_5a <-plot_strobe_diagram(incl_fontsize = 150, 
                                   excl_fontsize = 150, 
                                   export_file = "strobe-diagram_vignette2_5a.svg")
knitr::include_graphics(svg_file_2_5a)


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_5b <-plot_strobe_diagram(incl_fontsize = 150, 
                                   excl_fontsize = 150,
                                   incl_width_min = 20, excl_width_min = 30, 
                                   export_file = "strobe-diagram_vignette2_5b.svg")
knitr::include_graphics(svg_file_2_5b)


## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_6 <-plot_strobe_diagram(
  incl_width_min = 5,
  excl_width_min = 4,
  incl_height = 1.5,
  excl_height = 1.2,
  incl_fontsize = 18,
  excl_fontsize = 16,
  lock_width_min = TRUE,
  lock_height = TRUE,
  export_file = "strobe-diagram_vignette2_6.svg"
)
knitr::include_graphics(svg_file_2_6)


## ----out.width="50%", fig.align="center"--------------------------------------

#Add a terminal branch
cytomegalovirus_df<-create_terminal_branch(cytomegalovirus_df, variable = "cgvhd", label_prefix="CGVHD value:")

svg_file_2_7 <- plot_strobe_diagram(export_file = "strobe-diagram_vignette2_7.svg", 
                                incl_fontsize = 90, excl_fontsize = 90, 
                                lock_width_min = TRUE, 
                                incl_width_min = 20, excl_width_min = 20)
knitr::include_graphics("strobe-diagram_vignette2_7.svg")



## ----out.width="50%", fig.align="center"--------------------------------------
svg_file_2_8 <-plot_strobe_diagram(lock_width_min = TRUE,
                                   incl_width_min = 15,
                                   excl_width_min = 10,
                                   export_file = "strobe-diagram_vignette2_8.svg")
knitr::include_graphics("strobe-diagram_vignette2_8.svg")

## ----eval=FALSE---------------------------------------------------------------
# strobe_filter(
#   condition = "...",
#   inclusion_label = "Eligible recipients\nwith CMV+ donors",
#   exclusion_reason = "Excluded:\nCMV- donors"
# )

