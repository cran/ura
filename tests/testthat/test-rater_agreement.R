test_that("Percent agreement values are correct.", {

  test_data_1 <- tibble::tribble(
    ~rater,	~subject,	~coding,	~multi_coded,	~agree,	~percent_agree,
    1,	1,	1,	0,	NA,	50,
    1,	2,	0,	0,	NA,	50,
    1,	3,	1,	1,	1,	50,
    1,	4,	0,	1,	0,	50,
    2,	3,	1,	1,	1,	75,
    2,	9,	0,	0,	NA,	75,
    2,	10,	1,	0,	NA,	75,
    2,	4,	1,	1,	0,	75,
    2,	5,	1,	1,	1,	75,
    2,	6,	1,	1,	1,	75,
    3,	5,	1,	1,	1,	100,
    3,	6,	1,	1,	1,	100,
    3,	7,	1,	0,	NA,	100,
    3,	8,	1,	0,	NA,	100,
  )

  test_data_1_agree <- ura::rater_agreement(test_data_1,
                                            rater_column = 'rater',
                                            subject_column = 'subject',
                                            coding_column = 'coding')

  # test whether the the number of multi-coded actions per rater matches
  #   expectations set by the multi_coded column in the test dataset.
  check_multi_coded <- test_data_1 %>%
    dplyr::group_by(rater) %>%
    dplyr::summarise(n_multi_coded = sum(multi_coded))

  test_multi_coded <- dplyr::semi_join(test_data_1_agree,
                                       check_multi_coded,
                                       by = c("rater",
                                              "n_multi_coded")) %>%
    nrow()
  testthat::expect_equal(test_multi_coded,
                         nrow(test_data_1_agree))

  # test whether the percent agreement per rater matches the expectations set
  #   by the percent_agree column in the test dataset.
  check_percent_agree <- test_data_1 %>%
    dplyr::select(rater,
           percent_agree) %>%
    dplyr::distinct()

  test_percent_agree <- dplyr::semi_join(test_data_1_agree,
                                         check_percent_agree,
                                         by = c("rater",
                                                "percent_agree")) %>%
    nrow()
  testthat::expect_equal(test_percent_agree,
                         nrow(test_data_1_agree))

})





