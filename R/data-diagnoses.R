#' Psychiatric diagnoses of patients
#'
#' Data from Fleiss (1971) concerning the psychiatric conditions of thirty patients as
#' evaluated by six raters. The data are forked directly
#' from the \href{https://cran.r-project.org/package=irr}{irr package}, with the only difference being the shape of the dataset.
#'
#'
#' @format ## `diagnoses`
#' A data frame with 180 rows and 3 columns:
#' \describe{
#'   \item{patient_id}{The patient being screened for a psychiatric condition (numeric).}
#'   \item{rater_id}{The rater evaluating the patient for a psychiatric condition (numeric).}
#'   \item{diagnosis}{The psychiatric diagnosis of the patient (factor).}
#' }
#' @source Fleiss, J.L. (1971). Measuring nominal scale agreement among many raters. Psychological Bulletin,
#' 76, 378-382.
#' @references Fleiss, J.L. (1971). Measuring nominal scale agreement among many raters. Psychological Bulletin,
#' 76, 378-382.
"diagnoses"
