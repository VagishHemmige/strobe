# File: R/internal_env.R


#' Internal environment for package-level state
#'
#' This environment is used to store internal session-specific state of the STROBE derivation flow.
#' It is not exported and should not be accessed directly by users.
#'
#' @keywords internal
.strobe_env <- new.env(parent = emptyenv())

# STROBE diagram tracking table
.strobe_env$strobe_df <- tibble::tibble(
  id               = character(),  # Unique ID for each node
  parent           = character(),  # ID of parent node (if any)
  inclusion_label  = character(),  # Label for included patients (main path)
  exclusion_reason = character(),  # Optional: reason shown in side exclusion box
  filter           = character(),  # Filtering condition as text
  remaining        = integer(),    # Number of patients retained
  dropped          = integer()     # Number of patients excluded at this step
)

# Sequential tracking of steps and parent/child relationships
.strobe_env$strobe_step_counter <- 1L
.strobe_env$strobe_last_id <- "start"
