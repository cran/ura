#' irr_stats
#'
#' \code{irr_stats} calculates a variety of IRR statistics.
#' @param object_name A dataframe or tibble containing raters' codings. Each row should contain the assigned coding
#' from a given rater-subject.
#' @param rater_column The name of the column containing the raters' names as a string.
#' @param subject_column The name of the column containing the names of the subjects being coded as a string.
#' @param coding_column The name of the column containing the codings assigned by the raters as a string.
#' @param round_digits The number of decimals to round the IRR values by. The default is 2.
#' @param stats_to_include The IRR statistics to include in the output. Currently only supports percent agreement and Krippendorf's Alpha. See the documentation of the \href{https://cran.r-project.org/package=irr}{irr package} for more information about specific IRR statistics.
#' @return A tibble containing the IRR statistic, the statistic's value, and the number of subjects used to calculate the statistic.
#' @examples
#' # Return IRR statistics for the diagnoses dataset:
#' irr_stats(diagnoses,
#'           rater_column = 'rater_id',
#'           subject_column = 'patient_id',
#'           coding_column = 'diagnosis')
#'
#' # And IRR statistics for the anxiety dataset:
#' irr_stats(anxiety,
#'           rater_column = 'rater_id',
#'           subject_column = 'subject_id',
#'           coding_column = 'anxiety_level')
#'
#' @author Benjamin Goehring <bengoehr@umich.edu>
#' @export
irr_stats <- function(object_name,
                      rater_column,
                      subject_column,
                      coding_column,
                      round_digits = 2,
                      stats_to_include = c("Percentage agreement",
                                           "Krippendorf's Alpha")) {
  # run checks and return multi-coded subjects
  dbl_coded_df <- int_return_dbl_coded(in_object_name = object_name,
                                       in_rater_column = rater_column,
                                       in_subject_column = subject_column,
                                       in_coding_column = coding_column)

  # calculate the percent agreement, omitting NA values
  dbl_coded_df_wide <- dbl_coded_df %>%
    tidyr::pivot_wider(names_from = dplyr::all_of(rater_column),
                       values_from = dplyr::all_of(coding_column),
                       names_prefix = "rater_") %>%
    dplyr::rowwise() %>%
    dplyr::mutate(agree = dplyr::n_distinct(dplyr::c_across(dplyr::starts_with("rater_")),
                                            na.rm = T) == 1) %>%
    dplyr::ungroup()

  percent_agree <- 100 * (sum(dbl_coded_df_wide$agree) / nrow(dbl_coded_df_wide))
  percent_agree_n_subs <- nrow(dbl_coded_df_wide)

  # calculate the Krippendorf alpha. Note the different structure of the input
  #   dataset.
  kripp_matrix <- dbl_coded_df %>%
    tidyr::pivot_wider(names_from = dplyr::all_of(subject_column),
                       values_from = dplyr::all_of(coding_column),
                       names_prefix = "subject_") %>%
    dplyr::select(-dplyr::all_of(rater_column)) %>%
    as.matrix()

  kripp_alpha <- irr::kripp.alpha(kripp_matrix)$value
  kripp_alpha_n_subs <- irr::kripp.alpha(kripp_matrix)$subjects

  # save final dataset
  all_statistics_df <- tibble::tribble(
    ~statistic, ~value, ~n_subjects,
    "Percentage agreement", percent_agree, percent_agree_n_subs,
    "Krippendorf's Alpha", kripp_alpha, kripp_alpha_n_subs
  ) %>%
    dplyr::mutate(value = round(.data[['value']],
                                round_digits))

  return(all_statistics_df)
}




