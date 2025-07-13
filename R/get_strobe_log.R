#' Retrieve the STROBE Derivation Log
#'
#' Returns the current STROBE tracking data frame containing the sequence of
#' filtering steps, labels, and counts of included and excluded observations.
#'
#' @return A data frame with columns: `id`, `parent`, `inclusion_label`, `exclusion_reason`,
#'   `filter`, `remaining`, and `dropped`.
#' @export
#'
#' @examples
#' get_strobe_log()
get_strobe_log <- function() {
  log <- .strobe_env$strobe_df

  if (!is.data.frame(log) || nrow(log) == 0) {
    warning("No STROBE log initialized. Use `strobe_initialize()` first.")
    return(tibble::tibble(
      id = character(),
      parent = character(),
      inclusion_label = character(),
      exclusion_reason = character(),
      filter = character(),
      remaining = integer(),
      dropped = integer()
    ))
  }

  return(log)
}
