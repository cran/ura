#' Anxiety ratings
#'
#' Simulated data from three raters rating the anxiety of 20 individuals. The codings
#' range from 1 (no anxiety) to 6 (extremely anxious). The data are forked directly
#' from the \href{https://cran.r-project.org/package=irr}{irr package}, with the only difference being the shape of the dataset.
#'
#' @format ## `anxiety`
#' A data frame with 60 rows and 3 columns:
#' \describe{
#'   \item{subject_id}{The subject being screened for anxiety (numeric).}
#'   \item{rater_id}{The rater evaluating the subject for anxiety (numeric).}
#'   \item{anxiety_level}{The level of anxiety observed in the subject by the rater (numeric).}
#' }
#' @source <https://cran.r-project.org/package=irr>
"anxiety"
