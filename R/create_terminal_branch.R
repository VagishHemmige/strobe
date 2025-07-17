create_terminal_branch <- function(data, variable, label = NULL) {
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

  if (is.null(label)) {
    label <- paste0(var_name, ": ")
  }

  step_num <- .strobe_env$strobe_step_counter
  parent_id <- .strobe_env$strobe_last_id

  new_rows <- list()
  for (lvl in names(tab)) {
    new_rows[[length(new_rows) + 1]] <- tibble::tibble(
      id               = paste0("step", step_num),
      parent           = parent_id,
      inclusion_label  = paste0(label, lvl),
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
