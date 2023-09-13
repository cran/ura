#' int_return_dbl_coded
#'
#' \code{int_return_dbl_coded} An internal function to return the subjects double-coded by the raters. It runs a number of checks along the way
#' @param in_object_name A dataframe or tibble containing raters' codings. Each row should contain the assigned coding
#' from a given rater-subject.
#' @param in_rater_column The name of the column containing the raters' names as a string.
#' @param in_subject_column The name of the column containing the names of the subjects being coded as a string.
#' @param in_coding_column The name of the column containing the codings assigned by the raters as a string.
#' @author Benjamin Goehring <bengoehr@umich.edu>

int_return_dbl_coded <- function(in_object_name,
                                 in_rater_column,
                                 in_subject_column,
                                 in_coding_column) {

    # checks
  if(is.null(in_object_name)) {
    stop("object_name must be specified.")
  }
  if(!is.null(in_object_name) && !is.data.frame(in_object_name)) {
    stop("object_name must be a dataframe or tibble.")
  }
  if(is.null(in_rater_column) | is.null(in_subject_column) | is.null(in_coding_column)) {
    stop("rater_column, subject_column, and coding_column all must be specified.")
  }
  if(!is.character(in_rater_column) | !is.character(in_subject_column) | !is.character(in_coding_column)) {
    stop("rater_column, subject_column, and coding_column must be provided as strings.")
  }
  if(!all(c(in_rater_column, in_subject_column, in_coding_column) %in% colnames(in_object_name))) {
    stop("Either rater_column, subject_column or coding_column are not present in object_name")
  }
  if({
    in_object_name %>%
      dplyr::group_by(.data[[in_rater_column]],
                      .data[[in_subject_column]]) %>%
      dplyr::filter(dplyr::n() > 1) %>%
      nrow() != 0
  }) {
    stop("There are duplicates in the dataframe. Please be sure that there are no duplicate rater-subject observations.")
  }

  # NA warnings
  if(sum(is.na(dplyr::pull(in_object_name, .data[[in_rater_column]]))) > 0) {
    in_object_name <- in_object_name %>%
      dplyr::filter(!is.na(.data[[in_rater_column]]))

    warning("There are NA values in the rater column. Removing those rows.")
  }

  if(sum(is.na(dplyr::pull(in_object_name, .data[[in_subject_column]]))) > 0) {
    in_object_name <- in_object_name %>%
      dplyr::filter(!is.na(.data[[in_subject_column]]))

    warning("There are NA values in the subject column. Removing those rows.")
  }


  # filter input data down to only the multi-coded observations.
  in_object_name <- as.data.frame(in_object_name)

  dbl_coded_df <- in_object_name %>%
    dplyr::group_by(.data[[in_subject_column]]) %>%
    dplyr::filter(dplyr::n() > 1) %>%
    dplyr::ungroup()

    if(nrow(dbl_coded_df) == 0) {
    stop("There are no subjects coded by more than one rater. Therefore, IRR stats cannot be computed.")
  }
  if(!is.numeric(in_object_name[,in_subject_column])) {
    stop("The subject column is not numeric -- please recode")
  }
  if(!is.numeric(in_object_name[,in_rater_column])) {
    stop("The rater column is not numeric -- please recode")
  }
  if(!is.numeric(in_object_name[,in_coding_column])) {
    stop("The coding column is not numeric -- please recode")
  }

  # drop any additional columns
  dbl_coded_df <- dbl_coded_df %>%
    dplyr::select(dplyr::all_of(c(in_rater_column,
                                  in_subject_column,
                                  in_coding_column))) %>%
    dplyr::arrange(.data[[in_rater_column]])

    return(dbl_coded_df)
}


