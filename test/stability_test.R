source("tests/stability_test.R")

# ===================================
# ana包安全稳定性测试
# ===================================

# 请确保已经加载了您的ana包代码
# source("your_ana_package.R") 

# 安全的测试框架
safe_test <- function(test_name, test_func) {
  cat("\n")
  cat(paste(rep("-", 50), collapse = ""), "\n")
  cat("[测试]", test_name, "\n")
  cat(paste(rep("-", 50), collapse = ""), "\n")
  
  start_time <- Sys.time()
  
  result <- tryCatch({
    # 捕获输出以避免过多的输出干扰
    capture.output({
      test_func()
    }, type = "output")
    
    duration <- as.numeric(Sys.time() - start_time)
    cat("✓ 成功 (", round(duration, 3), "秒)\n")
    list(status = "SUCCESS", duration = duration, error = NULL)
    
  }, error = function(e) {
    duration <- as.numeric(Sys.time() - start_time)
    cat("✗ 失败:", e$message, "\n")
    list(status = "ERROR", duration = duration, error = e$message)
    
  }, warning = function(w) {
    duration <- as.numeric(Sys.time() - start_time)
    cat("⚠ 警告:", w$message, "\n")
    list(status = "WARNING", duration = duration, error = w$message)
  })
  
  return(result)
}

# 初始化测试结果
test_results <- list()

cat(paste(rep("=", 60), collapse = ""), "\n")
cat("ana包稳定性测试开始\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

# 测试1：基础功能测试
test_results[["基础功能"]] <- safe_test("基础功能 - iris数据集", function() {
  ana(iris, "Sepal.Length", "Species")
})

# 测试2：缺失值处理
test_na_data <- data.frame(
  x = c(1, 2, NA, 4, 5),
  y = c("a", "b", NA, "d", "e"),
  z = c(10.5, NA, 12.3, NA, 15.7)
)

test_results[["缺失值处理"]] <- safe_test("缺失值处理", function() {
  ana(test_na_data)
})

# 测试3：特殊数值处理
special_data <- data.frame(
  normal = 1:5,
  with_inf = c(1, 2, Inf, 4, 5),
  with_nan = c(1, 2, NaN, 4, 5),
  with_ninf = c(1, -Inf, 3, 4, 5)
)

test_results[["特殊数值"]] <- safe_test("特殊数值处理", function() {
  ana(special_data)
})

# 测试4：空数据框
test_results[["空数据框"]] <- safe_test("空数据框处理", function() {
  empty_df <- data.frame()
  ana(empty_df)
})

# 测试5：单一值变量
constant_data <- data.frame(
  constant_num = rep(5, 10),
  constant_char = rep("same", 10),
  normal_var = 1:10
)

test_results[["单一值变量"]] <- safe_test("单一值变量处理", function() {
  ana(constant_data)
})

# 测试6：混合数据类型
mixed_data <- data.frame(
  integer_col = 1L:5L,
  numeric_col = c(1.1, 2.2, 3.3, 4.4, 5.5),
  character_col = c("a", "b", "c", "d", "e"),
  factor_col = factor(c("low", "medium", "high", "low", "medium")),
  logical_col = c(TRUE, FALSE, TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE
)

test_results[["混合数据类型"]] <- safe_test("混合数据类型", function() {
  ana(mixed_data)
})

# 测试7：大量类别
many_categories <- data.frame(
  id = 1:30,
  category = paste0("category_", 1:30),
  value = rnorm(30)
)

test_results[["大量类别"]] <- safe_test("大量类别处理", function() {
  ana(many_categories, "category", "value")
})

# 测试8：不存在的变量
test_results[["不存在变量"]] <- safe_test("不存在变量处理", function() {
  ana(iris, "不存在的变量1", "不存在的变量2")
})

# 测试9：可视化功能
test_results[["可视化功能"]] <- safe_test("可视化功能", function() {
  alook(iris, "Sepal.Length", "Species")
})

# 测试10：全变量分析
test_results[["全变量分析"]] <- safe_test("全变量分析", function() {
  avar(mtcars)
})

# 测试11：中等规模数据
set.seed(123)
medium_data <- data.frame(
  matrix(rnorm(500 * 15), nrow = 500, ncol = 15)
)
names(medium_data) <- paste0("var_", 1:15)

test_results[["中等规模数据"]] <- safe_test("中等规模数据处理", function() {
  ana(medium_data)
})

# 测试12：高缺失率数据
set.seed(123)
sparse_data <- data.frame(
  var1 = ifelse(runif(100) < 0.7, NA, rnorm(100)),
  var2 = ifelse(runif(100) < 0.5, NA, sample(letters[1:5], 100, replace = TRUE)),
  var3 = ifelse(runif(100) < 0.8, NA, rpois(100, 3))
)

test_results[["高缺失率数据"]] <- safe_test("高缺失率数据处理", function() {
  ana(sparse_data)
})

# 测试结果汇总
cat("\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
cat("测试结果汇总\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

# 统计结果
total_tests <- length(test_results)
success_count <- sum(sapply(test_results, function(x) x$status == "SUCCESS"))
warning_count <- sum(sapply(test_results, function(x) x$status == "WARNING"))
error_count <- sum(sapply(test_results, function(x) x$status == "ERROR"))

cat("总测试数:", total_tests, "\n")
cat("成功:", success_count, sprintf("(%.1f%%)", success_count/total_tests*100), "\n")
cat("警告:", warning_count, sprintf("(%.1f%%)", warning_count/total_tests*100), "\n")
cat("错误:", error_count, sprintf("(%.1f%%)", error_count/total_tests*100), "\n")

# 计算稳定性得分
stability_score <- (success_count + warning_count * 0.5) / total_tests * 100

cat("\n稳定性得分:", sprintf("%.1f%%", stability_score), "\n")

# 稳定性评估
if (stability_score >= 90) {
  cat("🏆 评估: 优秀 - 代码非常稳定\n")
} else if (stability_score >= 75) {
  cat("✅ 评估: 良好 - 代码基本稳定\n")
} else if (stability_score >= 60) {
  cat("⚠️ 评估: 中等 - 需要改进\n")
} else {
  cat("❌ 评估: 较差 - 需要大幅改进\n")
}

# 失败测试详情
if (error_count > 0) {
  cat("\n失败的测试:\n")
  for (test_name in names(test_results)) {
    if (test_results[[test_name]]$status == "ERROR") {
      cat("• ", test_name, ":", test_results[[test_name]]$error, "\n")
    }
  }
}

# 性能分析
durations <- sapply(test_results[sapply(test_results, function(x) x$status == "SUCCESS")], 
                    function(x) x$duration)

if (length(durations) > 0) {
  cat("\n性能分析:\n")
  cat("平均执行时间:", sprintf("%.3f秒", mean(durations)), "\n")
  cat("最长执行时间:", sprintf("%.3f秒", max(durations)), "\n")
  
  # 找出最慢的测试
  slow_tests <- test_results[sapply(test_results, function(x) 
    x$status == "SUCCESS" && x$duration == max(durations))]
  if (length(slow_tests) > 0) {
    cat("最慢的测试:", names(slow_tests)[1], "\n")
  }
}

# 建议
cat("\n改进建议:\n")
if (error_count > 0) {
  cat("• 加强错误处理和输入验证\n")
}
if (warning_count > 0) {
  cat("• 优化警告信息处理\n")
}
if (max(durations, na.rm = TRUE) > 2) {
  cat("• 考虑优化性能，特别是大数据集处理\n")
}
cat("• 建议添加更多用户友好的提示信息\n")

cat("\n测试完成！\n")
cat(paste(rep("=", 60), collapse = ""), "\n")