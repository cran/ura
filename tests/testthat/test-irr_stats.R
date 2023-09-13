# set up test data.
#   Note that the input matrices need to be different depending on
#   kripp alpha or percent agree

anxiety_matrix_pct <- anxiety %>%
  tidyr::pivot_wider(values_from = anxiety_level,
              names_from = rater_id,
              names_prefix = "rater_") %>%
  dplyr::select(-subject_id) %>%
  as.matrix()

anxiety_matrix_kripp <- anxiety %>%
  tidyr::pivot_wider(values_from = anxiety_level,
                     names_from = subject_id,
                     names_prefix = "subject_") %>%
  dplyr::select(-rater_id) %>%
  as.matrix()

diagnoses_matrix_pct <- diagnoses %>%
  tidyr::pivot_wider(values_from = 'diagnosis',
              names_from = 'rater_id',
              names_prefix = "rater_") %>%
  dplyr::select(-patient_id) %>%
  dplyr::mutate(across(everything(),
                as.numeric)) %>%
  as.matrix()

diagnoses_matrix_kripp <- diagnoses %>%
  tidyr::pivot_wider(values_from = 'diagnosis',
                     names_from = 'patient_id',
                     names_prefix = "subject_") %>%
  dplyr::select(-rater_id) %>%
  dplyr::mutate(across(everything(),
                       as.numeric)) %>%
  as.matrix()

anxiety_test <- irr_stats(anxiety,
                          rater_column = "rater_id",
                          subject_column = "subject_id",
                          coding_column = "anxiety_level")

diagnoses_test <- irr_stats(diagnoses,
                            rater_column = "rater_id",
                            subject_column = "patient_id",
                            coding_column = "diagnosis")

test_that("Percent agreement value is correct (anxiety)", {

  anxiety_agree_test <- anxiety_test %>%
    dplyr::filter(statistic == "Percentage agreement") %>%
    dplyr::pull(value)
  expect_equal(irr::agree(anxiety_matrix_pct)$value,
               anxiety_agree_test)

})

test_that("Percent agreement value is correct (diagnoses)", {

   diagnoses_agree_test <- diagnoses_test %>%
     dplyr::filter(statistic == "Percentage agreement") %>%
     dplyr::pull(value)
  expect_equal(round(irr::agree(diagnoses_matrix_pct)$value, 2),
               round(diagnoses_agree_test, 2))

})

test_that("Kirppendorf's alpha is correct (anxiety)", {

  anxiety_kripp_test <- anxiety_test %>%
    dplyr::filter(statistic == "Krippendorf's Alpha") %>%
    dplyr::pull(value)
  expect_equal(round(irr::kripp.alpha(anxiety_matrix_kripp)$value, 2),
               anxiety_kripp_test)

})

test_that("Kirppendorf's alpha is correct (diagnoses)", {

  diagnoses_kripp_test <- diagnoses_test %>%
    dplyr::filter(statistic == "Krippendorf's Alpha") %>%
    dplyr::pull(value)
  expect_equal(round(irr::kripp.alpha(diagnoses_matrix_kripp)$value, 2),
               diagnoses_kripp_test)

})

test_that("Number of subjects is correct (anxiety)", {
  n_subs_test_anxiety <- anxiety_test %>%
    dplyr::pull(n_subjects) %>%
    unique()
  stopifnot(length(n_subs_test_anxiety) == 1)

  expect_equal(irr::agree(anxiety_matrix_pct)$subjects,
               n_subs_test_anxiety)
  expect_equal(irr::kripp.alpha(anxiety_matrix_kripp)$subjects,
               n_subs_test_anxiety)
})

test_that("Number of subjects is correct (diagnoses)", {
  n_subs_test_diagnoses <- diagnoses_test %>%
    dplyr::pull(n_subjects) %>%
    unique()
  stopifnot(length(n_subs_test_diagnoses) == 1)

  expect_equal(irr::agree(diagnoses_matrix_pct)$subjects,
               n_subs_test_diagnoses)
  expect_equal(irr::kripp.alpha(diagnoses_matrix_kripp)$subjects,
               n_subs_test_diagnoses)
})

#
test_that("Kripp example from IRR documentation", {
  nmm<-matrix(c(1,1,NA,1,2,2,3,2,3,3,3,3,3,3,3,3,2,2,2,2,1,2,3,4,4,4,4,4,
                1,1,2,1,2,2,2,2,NA,5,5,5,NA,NA,1,1,NA,NA,3,NA),nrow=4)
  kripp_doc_ex_subjects <- irr::kripp.alpha(nmm)$subjects
  kripp_doc_ex_value <- irr::kripp.alpha(nmm)$value

  nmm_example <- nmm %>%
    as.data.frame() %>%
    tibble::as_tibble(rownames = "rater") %>%
    tidyr::pivot_longer(V1:V12,
                 names_to = "subject",
                 values_to = "coding") %>%
    dplyr::mutate(subject = as.numeric(stringr::str_remove(subject,
                                           "V"))) %>%
    dplyr::mutate(rater = as.numeric(rater))

  krip_ura_df <- ura::irr_stats(nmm_example,
                                rater_column = 'rater',
                                subject_column = 'subject',
                                coding_column = 'coding')

  expect_equal(krip_ura_df %>%
                 dplyr::filter(statistic == "Krippendorf's Alpha") %>%
                 dplyr::pull(value),
               round(kripp_doc_ex_value, 2)
               )

  expect_equal(krip_ura_df %>%
                 dplyr::filter(statistic == "Krippendorf's Alpha") %>%
                 dplyr::pull(n_subjects),
               kripp_doc_ex_subjects)
})


