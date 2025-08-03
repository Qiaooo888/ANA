# Test file for ana package main functions
# Place in: tests/testthat/test-ana.R

library(testthat)
library(ana)

# Test data preparation
test_that("Test data can be created", {
  test_data <- data.frame(
    num_var = c(1, 2, 3, NA, 5),
    char_var = c("a", "b", "c", "d", NA),
    factor_var = factor(c("A", "B", "A", "B", NA)),
    logical_var = c(TRUE, FALSE, TRUE, NA, FALSE)
  )
  
  expect_s3_class(test_data, "data.frame")
  expect_equal(nrow(test_data), 5)
  expect_equal(ncol(test_data), 4)
})

# Test ana function
test_that("ana function works correctly", {
  test_data <- data.frame(
    num_var = c(1, 2, 3, NA, 5),
    char_var = c("a", "b", "c", "d", NA)
  )
  
  # Test with specific variables
  expect_silent(result <- ana(test_data, "num_var"))
  expect_type(result, "list")
  expect_true("基本信息" %in% names(result))
  
  # Test with all variables
  expect_silent(result_all <- ana(test_data))
  expect_type(result_all, "list")
  
  # Test with non-existent variable
  expect_warning(ana(test_data, "nonexistent_var"))
})

# Test input validation
test_that("ana handles invalid inputs correctly", {
  # Not a data frame
  expect_error(ana(list(a = 1, b = 2)))
  expect_error(ana(matrix(1:10, ncol = 2)))
  
  # Empty data frame
  empty_df <- data.frame()
  expect_message(ana(empty_df))
  
  # NULL input
  expect_error(ana(NULL))
})

# Test avar function
test_that("avar function works correctly", {
  test_data <- data.frame(
    num1 = 1:5,
    num2 = c(1.1, 2.2, 3.3, 4.4, 5.5),
    char1 = letters[1:5],
    factor1 = factor(c("A", "B", "A", "B", "A")),
    logical1 = c(TRUE, FALSE, TRUE, FALSE, TRUE)
  )
  
  expect_silent(result <- avar(test_data))
  expect_type(result, "list")
  expect_true("变量类型详情" %in% names(result))
  expect_true("缺失值汇总" %in% names(result))
  
  # Check variable type detection
  var_types <- result$变量类型详情
  expect_equal(nrow(var_types), 5)
  expect_true(all(c("变量名", "类型", "详细类型") %in% names(var_types)))
})

# Test helper functions
test_that("Helper functions work correctly", {
  # Test get_mode
  expect_equal(get_mode(c(1, 2, 2, 3, 3, 3)), 3)
  expect_equal(get_mode(c("a", "b", "b", "c")), "b")
  expect_true(is.na(get_mode(c())))
  expect_true(is.na(get_mode(c(NA, NA))))
  
  # Test safe_stat
  expect_equal(safe_stat(c(1, 2, 3, 4, 5), mean), 3)
  expect_equal(safe_stat(c(1, 2, NA, 4, 5), mean), 3)
  expect_true(is.na(safe_stat(c(NA, NA), mean)))
  expect_true(is.na(safe_stat(c(), mean)))
  
  # Test safe_format
  expect_equal(safe_format(3.14159, 2), "3.14")
  expect_equal(safe_format(NA), "NA")
  expect_equal(safe_format(Inf), "NA")
})

# Test remove_labels function
test_that("remove_labels handles different input types", {
  # Regular data frame
  df <- data.frame(a = 1:3, b = letters[1:3])
  result <- remove_labels(df)
  expect_equal(df, result)
  
  # Non-data frame input
  expect_equal(remove_labels(1:5), 1:5)
  expect_equal(remove_labels("test"), "test")
})

# Test validate_dataframe function
test_that("validate_dataframe works correctly", {
  # Valid data frame
  df <- data.frame(a = 1:3)
  expect_true(validate_dataframe(df, "test_df"))
  
  # Empty data frame
  empty_df <- data.frame()
  expect_false(validate_dataframe(empty_df, "empty_df"))
  
  # NULL input
  expect_error(validate_dataframe(NULL, "null_df"))
  
  # Not a data frame
  expect_error(validate_dataframe(1:5, "not_df"))
})