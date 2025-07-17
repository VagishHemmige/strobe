#' Create Terminal Branches in STROBE Diagram
#'
#' Finalizes the STROBE diagram by branching into terminal inclusion nodes based
#' on the values of a factor variable (e.g., outcome or stratifying variable).
#' The function throws an error if `variable` has more than six levels (including NA).
#'
#' @param data A data frame being tracked by STROBE.
#' @param variable A factor or character variable to split by.
#' @param label_prefix Optional prefix to prepend to each level in the inclusion label.
#' @return The input data frame (unchanged).
#' @export
create_terminal_branch <- function(data, variable, label_prefix = NULL) {
  stopifnot(is.data.frame(data))

  MAX_TERMINAL_BRANCHES <- 6L

  # Capture symbol or string and resolve to column name
  var_sym <- rlang::ensym(variable)  # accepts both unquoted and quoted
  var_name <- rlang::as_string(var_sym)

  vals <- data[[var_name]]

  # Coerce to factor, preserving NA as a level
  if (!is.factor(vals)) {
    vals <- factor(vals, exclude = NULL)
  }

  # Count levels (including NA)
  tab <- table(vals, useNA = "ifany")
  n_levels <- length(tab)

  if (n_levels > MAX_TERMINAL_BRANCHES) {
    stop(sprintf(
      "Variable '%s' has %d levels (including NA). Maximum allowed for terminal branches is %d.",
      var_name, n_levels, MAX_TERMINAL_BRANCHES
    ))
  }

  if (is.null(label_prefix)) {
    label_prefix <- ""
  }

  step_num <- .strobe_env$strobe_step_counter
  parent_id <- .strobe_env$strobe_last_id

  new_rows <- list()
  for (lvl in names(tab)) {
    new_rows[[length(new_rows) + 1]] <- tibble::tibble(
      id               = paste0("step", step_num),
      parent           = parent_id,
      inclusion_label  = paste0(label_prefix, lvl),
      exclusion_reason = NA_character_,
      filter           = NA_character_,
      remaining        = as.integer(tab[[lvl]]),
      dropped          = NA_integer_
    )
    step_num <- step_num + 1L
  }

  .strobe_env$strobe_df <- dplyr::bind_rows(.strobe_env$strobe_df, new_rows)
  .strobe_env$strobe_step_counter <- step_num

  return(invisible(data))
}
