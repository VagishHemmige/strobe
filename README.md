
# strobe: Tools for STROBE-Style Inclusion and Exclusion Tracking with patient-level data

<!-- badges: start -->

<!-- badges: end -->

The `strobe` package provides tools for **tracking cohort
inclusion/exclusion** in observational studies using a STROBE-inspired
flow. STROBE (Strengthening the Reporting of Observational Studies in
Epidemiology) is a widely adopted guideline for transparent reporting of
cohort, case-control, and cross-sectional studies. Learn more at the
official website: <https://www.strobe-statement.org/>.

The `strobe` package both applies filtering criteria to a patient-level
data frame while tracking the number of patients excluded and included
at each step. The package can also print and/or save the final STROBE
diagram for inclusion in a publication.

By logging each filtering step—conditions applied, number remaining, and
number excluded—`strobe` helps ensure reproducibility, clarity, and
publication-quality documentation of cohort derivation.

## Installation

You can install the development version of `strobe` from
[GitHub](https://github.com/VagishHemmige/strobe) with:

``` r
# install.packages("devtools")
devtools::install_github("VagishHemmige/strobe")
```

## Example

*Note: The example below requires the `medicaldata` package. Install it
with:*

``` r
install.packages("medicaldata")
```

We now create an SVG plot in R and then print the strobe log with the
`get_strobe_log` function.

``` r
library(strobe)
library(medicaldata)
data(cytomegalovirus)

df <- strobe_initialize(cytomegalovirus, "Initial CMV transplant cohort")
df <- strobe_filter(df, "age >= 30", "Age ≥ 30", "Excluded: Age < 30")
df <- strobe_filter(df, "recipient.cmv == 1", "Recipient CMV positive", "Excluded: CMV negative")

get_strobe_log()
#> # A tibble: 3 × 7
#>   id    parent inclusion_label         exclusion_reason filter remaining dropped
#>   <chr> <chr>  <chr>                   <chr>            <chr>      <int>   <int>
#> 1 start <NA>   Initial CMV transplant… <NA>             <NA>          64      NA
#> 2 step1 start  Age ≥ 30                Excluded: Age <… age >…        63       1
#> 3 step2 step1  Recipient CMV positive  Excluded: CMV n… recip…        40      23
```

We plot the STROBE diagram associated with the above code.
Interactively, the `plot_strobe_diagram()` function can also directly
create plots that can be viewed in the Rstudio viewer, but direct
visualization in an .rmd file which has been knitted may cause
formatting issues.

``` r
svg_file_1 <- plot_strobe_diagram(export_file = "man/figures/strobe-diagram_readme1_1.svg", 
                                incl_fontsize = 90, excl_fontsize = 90, 
                                lock_width_min = TRUE, 
                                incl_width_min = 20, excl_width_min = 15)
knitr::include_graphics("man/figures/strobe-diagram_readme1_1.svg")
```

<img src="man/figures/strobe-diagram_readme1_1.svg" width="100%" />

The `strobe` package can also support terminal branching based on the
value of a factor variable, if the factor variable has six or fewer
distinct values:

``` r
#Add terminal branch based on the value of the variable

df<-create_terminal_branch(df, variable = "cgvhd", label_prefix="CGVHD value:")
get_strobe_log()
#> # A tibble: 5 × 7
#>   id    parent inclusion_label         exclusion_reason filter remaining dropped
#>   <chr> <chr>  <chr>                   <chr>            <chr>      <int>   <int>
#> 1 start <NA>   Initial CMV transplant… <NA>             <NA>          64      NA
#> 2 step1 start  Age ≥ 30                Excluded: Age <… age >…        63       1
#> 3 step2 step1  Recipient CMV positive  Excluded: CMV n… recip…        40      23
#> 4 step3 step2  CGVHD value:0           <NA>             <NA>          22      NA
#> 5 step4 step2  CGVHD value:1           <NA>             <NA>          18      NA
```

The `plot_strobe_diagram` function can handle terminal branching:

``` r
svg_file_2 <- plot_strobe_diagram(export_file = "man/figures/strobe-diagram_readme1_2.svg", 
                                incl_fontsize = 90, excl_fontsize = 90, 
                                lock_width_min = TRUE, 
                                incl_width_min = 20, excl_width_min = 15)
knitr::include_graphics("man/figures/strobe-diagram_readme1_2.svg")
```

<img src="man/figures/strobe-diagram_readme1_2.svg" width="100%" />
