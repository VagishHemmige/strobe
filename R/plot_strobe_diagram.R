#' Plot STROBE Derivation Diagram
#'
#' Creates a STROBE flow diagram from the filtering log recorded via
#' `strobe_initialize()` and `strobe_filter()`. The main inclusion path flows
#' top-to-bottom, and exclusions are drawn as horizontal arrows pointing to
#' dashed boxes to the right, originating from the connecting lines.
#'
#' @param export_file Optional file path (e.g., "diagram.png" or "diagram.svg") to save the diagram.
#' @param incl_width_min Width of inclusion boxes in inches. If `NULL`, auto-sizes to content.
#' @param incl_height Height of inclusion boxes in inches. If `NULL`, auto-sizes to content.
#' @param excl_width_min Width of exclusion boxes in inches. If `NULL`, auto-sizes to content.
#' @param excl_height Height of exclusion boxes in inches. If `NULL`, auto-sizes to content.
#' @param incl_fontsize Font size for inclusion box text (default = 14).
#' @param excl_fontsize Font size for exclusion box text (default = 12).
#' @param lock_width_min Logical. If `TRUE`, treats `incl_width_min` and `excl_width_min`
#'   as minimum widths. Due to Graphviz limitations, widths are lower bounds only—
#'   content may still expand boxes beyond these values.
#' @param lock_height Logical. If `TRUE`, enforces exact box heights for all nodes.
#'
#' @importFrom htmltools tagList

#'
#' @return A `DiagrammeR` graph object representing the STROBE diagram.
#' @export

plot_strobe_diagram <- function(export_file = NULL,
                                incl_width_min = 3, incl_height = NULL,
                                excl_width_min = 2.5, excl_height = NULL,
                                incl_fontsize = 14, excl_fontsize = 12,
                                lock_width_min = FALSE, lock_height = FALSE) {
  if (is.null(.strobe_env$strobe_df) || nrow(.strobe_env$strobe_df) == 0) {
    stop("No STROBE log found. Run strobe_initialize() and at least one strobe_filter() step.")
  }
  df <- .strobe_env$strobe_df

  # Inclusion node labels
  incl_labels <- paste0(df$inclusion_label, "\n(n = ", df$remaining, ")")

  # Exclusion nodes (dashed side boxes)
  excl_idx <- which(!is.na(df$exclusion_reason))
  excl_labels <- if (length(excl_idx) > 0) {
    paste0(df$exclusion_reason[excl_idx], "\n(n = ", df$dropped[excl_idx], ")")
  } else {
    character(0)
  }

  # Build DOT code directly for proper STROBE layout
  dot_code <- paste0(
    "digraph strobe {\n",
    "  rankdir=TB;\n",
    "  ranksep=1.5;\n",
    "  nodesep=3;\n",
    "  node [fontname=Arial];\n",
    "  edge [fontname=Arial];\n",
    "  \n"
  )

  # Helper function to build size attributes
  build_size_attrs <- function(width, height, lock_width_min, lock_height) {
    size_attrs <- ""

    if (lock_width_min && lock_height) {
      # Lock minimum width and exact height
      if (!is.null(width)) {
        size_attrs <- paste0(size_attrs, "width=", width, ", ")
      }
      if (!is.null(height)) {
        size_attrs <- paste0(size_attrs, "height=", height, ", ")
      }
      if (!is.null(height)) {
        size_attrs <- paste0(size_attrs, "fixedsize=shape, ")
      }
    } else if (lock_width_min && !lock_height) {
      # Lock minimum width only - width acts as minimum constraint
      if (!is.null(width)) {
        size_attrs <- paste0(size_attrs, "width=", width, ", ")
      }
      # No fixedsize - width is minimum, height is flexible
    } else if (lock_height && !lock_width_min) {
      # Lock exact height only
      if (!is.null(height)) {
        size_attrs <- paste0(size_attrs, "height=", height, ", fixedsize=shape, ")
      }
      # Don't specify width to allow flexibility
    } else {
      # Neither locked - provide hints but allow full flexibility
      if (!is.null(width)) {
        size_attrs <- paste0(size_attrs, "width=", width, ", ")
      }
      if (!is.null(height)) {
        size_attrs <- paste0(size_attrs, "height=", height, ", ")
      }
      # No fixedsize - completely flexible
    }

    return(size_attrs)
  }

  # Add inclusion nodes
  for (i in 1:nrow(df)) {
    size_attrs <- build_size_attrs(incl_width_min, incl_height, lock_width_min, lock_height)

    dot_code <- paste0(dot_code,
                       "  incl", i, " [label=\"", gsub("\"", "\\\"", incl_labels[i]), "\", ",
                       "shape=box, style=solid, fontsize=", incl_fontsize, ", ",
                       size_attrs, "margin=0.2];\n"
    )
  }

  # Add exclusion nodes
  if (length(excl_idx) > 0) {
    for (i in seq_along(excl_idx)) {
      size_attrs <- build_size_attrs(excl_width_min, excl_height, lock_width_min, lock_height)

      dot_code <- paste0(dot_code,
                         "  excl", i, " [label=\"", gsub("\"", "\\\"", excl_labels[i]), "\", ",
                         "shape=box, style=dashed, fontsize=", excl_fontsize, ", ",
                         size_attrs, "margin=0.2];\n"
      )
    }
  }

  # Add invisible nodes at midpoints for exclusion arrows
  if (length(excl_idx) > 0) {
    for (i in seq_along(excl_idx)) {
      dot_code <- paste0(dot_code,
                         "  mid", i, " [shape=point, style=invis, width=0, height=0];\n"
      )
    }
  }

  dot_code <- paste0(dot_code, "\n")

  # Add inclusion edges and midpoint connections
  excl_counter <- 1

  # Process each row to create edges
  for (i in 1:nrow(df)) {
    if (!is.na(df$parent[i])) {
      # Find the parent node index
      parent_row <- which(df$id == df$parent[i])
      child_row <- i

      # Check if this transition has an exclusion
      has_exclusion <- child_row %in% excl_idx

      if (has_exclusion) {
        # Split the edge: parent -> midpoint -> child
        dot_code <- paste0(dot_code,
                           "  incl", parent_row, " -> mid", excl_counter, " [arrowhead=none, color=black];\n",
                           "  mid", excl_counter, " -> incl", child_row, " [arrowhead=normal, color=black];\n"
        )

        # Add rank constraint to keep midpoint and exclusion box aligned
        dot_code <- paste0(dot_code,
                           "  {rank=same; mid", excl_counter, "; excl", excl_counter, ";}\n"
        )

        # Add exclusion arrow from midpoint to exclusion box
        dot_code <- paste0(dot_code,
                           "  mid", excl_counter, " -> excl", excl_counter,
                           " [arrowhead=normal, color=gray40];\n"
        )

        excl_counter <- excl_counter + 1
      } else {
        # Normal inclusion edge
        dot_code <- paste0(dot_code,
                           "  incl", parent_row, " -> incl", child_row,
                           " [arrowhead=normal, color=black];\n"
        )
      }
    }
  }

  dot_code <- paste0(dot_code, "}\n")

  # Optional export
  if (!is.null(export_file)) {
    # Create the graph object for export
    g <- DiagrammeR::grViz(dot_code)

    ext <- tools::file_ext(export_file)
    if (!requireNamespace("DiagrammeRsvg", quietly = TRUE) ||
        !requireNamespace("rsvg", quietly = TRUE)) {
      stop("To export the diagram, install both DiagrammeRsvg and rsvg packages.")
    }
    svg <- DiagrammeRsvg::export_svg(g)
    raw <- charToRaw(svg)
    if (tolower(ext) == "png") {
      rsvg::rsvg_png(raw, file = export_file)
    } else if (tolower(ext) == "svg") {
      writeLines(svg, con = export_file)
    } else {
      stop("Unsupported export format. Use .png or .svg.")
    }
  }

  g <- DiagrammeR::grViz(dot_code)


  # Handle different rendering contexts
  if (!interactive() && requireNamespace("knitr", quietly = TRUE) && knitr::is_html_output()) {
    # For R Markdown HTML knitting, convert to PNG to avoid widget issues
    if (requireNamespace("DiagrammeRsvg", quietly = TRUE) &&
        requireNamespace("rsvg", quietly = TRUE)) {
      temp_file <- tempfile(fileext = ".png")
      svg <- DiagrammeRsvg::export_svg(g)
      rsvg::rsvg_png(charToRaw(svg), file = temp_file)
      return(knitr::include_graphics(temp_file))
    } else {
      # If conversion packages not available, try widget approach
      if (requireNamespace("htmltools", quietly = TRUE)) {
        return(htmltools::tagList(g))
      } else {
        return(g)
      }
    }
  } else {
    # Interactive mode or non-HTML output
    return(g)
  }
}
