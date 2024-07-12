#' rater_agreement
#'
#' \code{rater_agreement} calculates the percent agreement between each rater and the other raters who coded the same subjects.
#' @param object_name A dataframe or tibble containing raters' codings. Each row should contain the assigned coding
#' from a given rater-subject.
#' @param rater_column The name of the column containing the raters' names as a string.
#' @param subject_column The name of the column containing the names of the subjects being coded as a string.
#' @param coding_column The name of the column containing the codings assigned by the raters as a string.
#' @return A tibble where each row notes the percent agreement between rater i and all other raters who coded the same subjects (percent_agree).
#' The n_multi_coded column notes how many subjects have been coded by rater i that have also been coded by other raters (i.e., the denominator for the percent_agree value).
#' @examples
#' # Example data: 3 raters assigning binary values to 10 subjects
#' example_data <- tibble::tribble(
#'   ~rater,	~subject,	~coding,
#'   1,	1,	1,
#'   1,	2,	0,
#'   1,	3,	1,
#'   1,	4,	0,
#'   2,	3,	1,
#'   2,	9,	0,
#'   2,	10,	1,
#'   2,	4,	1,
#'   2,	5,	1,
#'   2,	6,	1,
#'   3,	5,	1,
#'   3,	6,	1,
#'   3,	7,	1,
#'   3,	8,	1,
#' )
#'
#' # Find percent agreement by rater
#' rater_agreement(example_data,
#'                 rater_column = 'rater',
#'                 subject_column = 'subject',
#'                 coding_column = 'coding')
#'
#'
#' @author Benjamin Goehring <bengoehr@umich.edu>
#' @export

rater_agreement <- function(object_name,
                            rater_column,
                            subject_column,
                            coding_column) {

  # run checks and return subjects coded by more than one rater
  dbl_coded_df <- int_return_dbl_coded(in_object_name = object_name,
                                       in_rater_column = rater_column,
                                       in_subject_column = subject_column,
                                       in_coding_column = coding_column)

  # Loop thorugh the raters, calculating for each rater the share of observations
  #   that match with all other raters that coded those given subjects.
  raters <- unique(dplyr::pull(dplyr::select(object_name,
                                             dplyr::all_of(rater_column))))
  all_pct_agree <- vector('list',
                          length = length(raters))

  for(i in 1:length(raters)) {

    # return the subjects coded by rater i
    rater_i <- raters[i]

    rater_i_ids <- dbl_coded_df %>%
      dplyr::filter(.data[[rater_column]] == rater_i) %>%
      dplyr::pull(.data[[subject_column]])

    subjects_i <- dbl_coded_df %>%
      dplyr::filter(.data[[subject_column]] %in% rater_i_ids)

    # spin data wide by rater
    subjects_wide <- subjects_i %>%
      tidyr::pivot_wider(values_from = dplyr::all_of(coding_column),
                  names_from = dplyr::all_of(rater_column),
                  names_prefix = "rater_")

    subjects_wide <- subjects_wide %>%
      dplyr::rowwise() %>%
      dplyr::mutate(agree = dplyr::n_distinct(dplyr::c_across(dplyr::starts_with("rater_")),
                                              na.rm = T) == 1) %>%
      dplyr::ungroup()

    final <- subjects_wide %>%
      dplyr::summarise(percent_agree = 100 * round(sum(.data[['agree']]) / dplyr::n(), 2))

    all_pct_agree[[i]] <- tibble::tibble(rater = rater_i,
                                         percent_agree = dplyr::pull(final,
                                                                     .data[['percent_agree']]),
                                         n_multi_coded = nrow(subjects_wide))

  }



  final <- all_pct_agree %>%
    dplyr::bind_rows() %>%
    dplyr::arrange(dplyr::desc(.data[['percent_agree']]))

  return(final)
}


