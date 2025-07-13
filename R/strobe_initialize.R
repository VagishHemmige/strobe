#' Initialize STROBE Tracking
#'
#' Starts a new STROBE derivation log for a cohort by recording the initial data frame's size.
#' This function must be called once, before any filtering steps.
#' Internally, it creates the first row of the tracking table and resets the step counter.
#'
#' @param data A data frame representing the initial eligible cohort.
#' @param inclusion_label A human-readable label describing the initial cohort.
#'   This will appear in the main path of the STROBE diagram.
#'   Default is "Initial eligible cohort".
#'
#' @return The same data frame, unchanged.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- strobe_initialize(my_data, inclusion_label = "Adults age 18+ in registry")
#' }
strobe_initialize <- function(data, inclusion_label = "Initial eligible cohort") {
  stopifnot(is.data.frame(data))

  n <- nrow(data)

  .strobe_env$strobe_df <- tibble::tibble(
    id               = "start",
    parent           = NA_character_,
    inclusion_label  = inclusion_label,
    exclusion_reason = NA_character_,
    filter           = NA_character_,
    remaining        = n,
    dropped          = NA_integer_
  )

  .strobe_env$strobe_step_counter <- 1L
  .strobe_env$strobe_last_id <- "start"

  return(data)
}
