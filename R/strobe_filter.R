#' Apply a Sequential Filtering Step for STROBE Tracking
#'
#' Filters a data frame based on a condition and records the effect of that filter
#' (number retained and excluded) in the STROBE tracking table.
#' Steps are automatically numbered and linked in sequence.
#'
#' @param data A data frame to be filtered.
#' @param condition A filtering condition as a character string (e.g., `"age >= 18"`).
#' @param inclusion_label A human-readable description of the remaining cohort after filtering.
#' @param exclusion_reason Optional. A label describing the exclusion criterion, which will be shown
#'   as a side box in the STROBE diagram. If NULL, no exclusion box will be added.
#'
#' @return The filtered data frame after applying the condition.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- strobe_initialize(my_data)
#' df <- strobe_filter(df,
#'   condition = "age >= 18",
#'   inclusion_label = "Age ≥ 18",
#'   exclusion_reason = "Excluded: Age < 18"
#' )
#' }
strobe_filter <- function(data, condition, inclusion_label, exclusion_reason = NULL) {
  stopifnot(is.data.frame(data))

  if (!is.character(condition) || length(condition) != 1) {
    stop("`condition` must be a single character string, like \"age >= 18\".")
  }

  # Parse condition string into an R expression
  condition_expr <- tryCatch(
    parse(text = condition)[[1]],
    error = function(e) stop("Failed to parse condition: ", condition)
  )

  # Evaluate filter
  original_n <- nrow(data)
  filtered_data <- data[eval(condition_expr, envir = data, enclos = parent.frame()), ]
  remaining_n <- nrow(filtered_data)

  # Step metadata
  step_num <- .strobe_env$strobe_step_counter
  step_id <- paste0("step", step_num)
  parent_id <- .strobe_env$strobe_last_id

  # Update tracking table
  .strobe_env$strobe_df <- dplyr::bind_rows(
    .strobe_env$strobe_df,
    tibble::tibble(
      id               = step_id,
      parent           = parent_id,
      inclusion_label  = inclusion_label,
      exclusion_reason = exclusion_reason,
      filter           = condition,
      remaining        = remaining_n,
      dropped          = original_n - remaining_n
    )
  )

  # Increment state
  .strobe_env$strobe_step_counter <- step_num + 1L
  .strobe_env$strobe_last_id <- step_id

  return(filtered_data)
}
