# ===================================
# ana包 - 稳定版1.0
# ===================================

# 自动检查和加载必要的包
.check_packages <- function() {
  packages <- c("tidyverse", "haven")
  
  # 检查并安装缺失的包
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages) > 0) {
    message("正在安装缺失的包: ", paste(new_packages, collapse = ", "))
    tryCatch({
      install.packages(new_packages, quiet = TRUE)
    }, error = function(e) {
      stop("无法安装必要的包，请手动安装: ", paste(new_packages, collapse = ", "))
    })
  }
  
  # 加载包
  for (pkg in packages) {
    tryCatch({
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    }, error = function(e) {
      stop("无法加载包 ", pkg, "，请检查安装")
    })
  }
}

# 启动时运行
.check_packages()


# 辅助函数：增强的数据框验证（优化：更好地处理边界条件）
validate_dataframe <- function(data, data_name_str, allow_empty = FALSE) {
  if (is.null(data)) {
    stop("数据为NULL，请提供有效的数据框")
  }
  
  if (!is.data.frame(data)) {
    stop("输入必须是数据框，当前类型: ", class(data)[1], 
         "\n提示：请使用 data.frame() 或 as.data.frame() 转换数据")
  }
  
  # 优化：空数据框处理 - 不直接报错，而是给出友好提示
  if (nrow(data) == 0 && !allow_empty) {
    message("注意：数据框 '", data_name_str, "' 为空（0行）")
    return(FALSE)  # 返回FALSE表示无法继续分析
  }
  
  if (ncol(data) == 0 && !allow_empty) {
    message("注意：数据框 '", data_name_str, "' 没有列")
    return(FALSE)
  }
  
  return(TRUE)
}

# 辅助函数：清除haven标签
remove_labels <- function(data) {
  if (!is.data.frame(data)) {
    return(data)
  }
  
  tryCatch({
    data %>%
      mutate(across(everything(), ~{
        if (haven::is.labelled(.x)) {
          as.vector(.x)
        } else {
          .x
        }
      }))
  }, error = function(e) {
    # 如果haven相关函数失败，返回原数据
    data
  })
}

# 辅助函数：安全计算众数
get_mode <- function(x) {
  if (length(x) == 0 || all(is.na(x))) return(NA)
  
  # 移除NA、NaN和无穷值
  x_clean <- x[!is.na(x) & !is.nan(x)]
  if (is.numeric(x)) {
    x_clean <- x_clean[is.finite(x_clean)]
  }
  
  if (length(x_clean) == 0) return(NA)
  
  # 对于数值型，如果所有值都不同，返回NA
  if (is.numeric(x_clean) && length(unique(x_clean)) == length(x_clean)) {
    return(NA)
  }
  
  tbl <- table(x_clean)
  if (length(tbl) == 0) return(NA)
  
  modes <- names(tbl)[tbl == max(tbl)]
  if (is.numeric(x)) {
    return(suppressWarnings(as.numeric(modes[1])))
  } else {
    return(as.character(modes[1]))
  }
}

# 辅助函数：安全计算统计量
safe_stat <- function(x, fun, digits = 4) {
  if (!is.numeric(x) || length(x) == 0) return(NA)
  
  # 移除特殊值
  x_clean <- x[!is.na(x) & !is.nan(x) & is.finite(x)]
  if (length(x_clean) == 0) return(NA)
  
  result <- tryCatch({
    fun(x_clean, na.rm = TRUE)
  }, error = function(e) {
    NA
  }, warning = function(w) {
    suppressWarnings(fun(x_clean, na.rm = TRUE))
  })
  
  if (is.numeric(result) && length(result) == 1 && is.finite(result)) {
    round(result, digits)
  } else {
    NA
  }
}

# 辅助函数：安全格式化数值
safe_format <- function(x, digits = 2) {
  if (is.na(x) || !is.numeric(x) || !is.finite(x)) {
    return("NA")
  }
  format(round(x, digits), scientific = FALSE)
}

# 函数一：ana - 基础分析（优化版）
ana <- function(data_name, ...) {
  # 获取数据和名称
  data <- data_name
  data_name_str <- deparse(substitute(data_name))
  
  # 优化：改进数据验证 - 空数据框不直接报错
  validation_result <- tryCatch({
    validate_dataframe(data, data_name_str)
  }, error = function(e) {
    stop("数据验证失败: ", e$message)
  })
  
  # 如果验证失败（如空数据框），友好处理
  if (!validation_result) {
    cat("\n========== 数据分析报告 ==========\n")
    cat("数据集: ", data_name_str, "\n")
    cat("状态: 数据框为空，无法进行分析\n")
    cat("建议: 请检查数据加载过程或数据筛选条件\n")
    cat("=====================================\n")
    return(invisible(list(
      数据集 = data_name_str,
      状态 = "空数据框",
      行数 = ifelse(is.data.frame(data), nrow(data), 0),
      列数 = ifelse(is.data.frame(data), ncol(data), 0)
    )))
  }
  
  # 清除标签
  data <- remove_labels(data)
  
  # 获取变量名
  var_names <- c(...)
  
  # 如果没有指定变量名，分析所有数值型和因子型变量（前10个）
  if (length(var_names) == 0) {
    # 自动选择适合分析的变量
    all_vars <- names(data)
    suitable_vars <- c()
    
    for (var in all_vars) {
      col <- data[[var]]
      if (is.numeric(col) || is.factor(col) || is.logical(col) || is.character(col)) {
        suitable_vars <- c(suitable_vars, var)
      }
    }
    
    if (length(suitable_vars) == 0) {
      cat("\n========== 数据分析报告 ==========\n")
      cat("数据集: ", data_name_str, "\n")
      cat("状态: 没有找到适合分析的变量\n")
      cat("说明: 请确保数据包含数值型、因子型、逻辑型或字符型变量\n")
      cat("=====================================\n")
      return(invisible(list(
        数据集 = data_name_str,
        状态 = "无适合变量"
      )))
    }
    
    # 限制变量数量
    if (length(suitable_vars) > 10) {
      var_names <- suitable_vars[1:10]
      message("未指定变量，自动选择前10个适合分析的变量")
    } else {
      var_names <- suitable_vars
      message("未指定变量，自动分析所有", length(suitable_vars), "个适合的变量")
    }
  }
  
  # 优化：改进变量名验证和处理
  var_names <- unique(var_names)  # 去重
  missing_vars <- var_names[!var_names %in% names(data)]
  
  if (length(missing_vars) > 0) {
    warning("以下变量不存在: ", paste(missing_vars, collapse = ", "))
    var_names <- var_names[var_names %in% names(data)]
    
    # 优化：当所有指定变量都不存在时的处理
    if (length(var_names) == 0) {
      cat("\n========== 数据分析报告 ==========\n")
      cat("数据集: ", data_name_str, "\n")
      cat("状态: 指定的变量都不存在\n")
      cat("可用变量: ", paste(names(data), collapse = ", "), "\n")
      cat("建议: 请检查变量名拼写或使用 names(", data_name_str, ") 查看所有变量\n")
      cat("=====================================\n")
      return(invisible(list(
        数据集 = data_name_str,
        状态 = "变量不存在",
        可用变量 = names(data)
      )))
    } else {
      message("将继续分析存在的变量: ", paste(var_names, collapse = ", "))
    }
  }
  
  cat("\n========== 数据分析报告 ==========\n")
  cat("数据集: ", data_name_str, "\n")
  cat("分析变量: ", paste(var_names, collapse = ", "), "\n")
  cat("数据规模: ", nrow(data), "行 × ", ncol(data), "列\n")
  cat("=====================================\n")
  
  # 表格一：变量基本信息
  cat("\n表格一：变量基本信息\n")
  cat("-------------------------------------\n")
  
  table1 <- data.frame(
    变量名 = character(),
    类型 = character(),
    有效值 = integer(),
    缺失值 = character(),
    取值信息 = character(),
    stringsAsFactors = FALSE
  )
  
  for (var in var_names) {
    if (!var %in% names(data)) next
    
    col <- data[[var]]
    
    # 确定类型（增强版）
    type <- tryCatch({
      if (is.complex(col)) {
        "复数型"
      } else if (is.numeric(col) && !is.integer(col)) {
        "连续型"
      } else if (is.integer(col)) {
        "整数型"
      } else if (is.factor(col)) {
        "因子型"
      } else if (is.logical(col)) {
        "逻辑型"
      } else if (inherits(col, "Date")) {
        "日期型"
      } else if (inherits(col, "POSIXt")) {
        "日期时间型"
      } else if (is.character(col)) {
        "字符型"
      } else if (is.list(col)) {
        "列表型"
      } else {
        paste0("其他(", class(col)[1], ")")
      }
    }, error = function(e) "未知")
    
    # 基本统计
    n_total <- length(col)
    n_valid <- sum(!is.na(col))
    n_missing <- sum(is.na(col))
    pct_missing <- round(n_missing / n_total * 100, 2)
    
    # 取值信息（增强版）
    value_info <- tryCatch({
      if (type %in% c("连续型", "整数型") && n_valid > 0) {
        # 检查特殊值
        n_inf <- sum(is.infinite(col), na.rm = TRUE)
        n_nan <- sum(is.nan(col), na.rm = TRUE)
        
        if (n_inf > 0 || n_nan > 0) {
          special_info <- paste0(
            if(n_inf > 0) paste0(n_inf, "个Inf") else NULL,
            if(n_inf > 0 && n_nan > 0) ", " else "",
            if(n_nan > 0) paste0(n_nan, "个NaN") else NULL
          )
          paste0("含特殊值(", special_info, ")")
        } else {
          min_val <- safe_stat(col, min)
          max_val <- safe_stat(col, max)
          if (!is.na(min_val) && !is.na(max_val)) {
            paste0("[", safe_format(min_val), ", ", safe_format(max_val), "]")
          } else {
            "无有效范围"
          }
        }
      } else if (type %in% c("因子型", "逻辑型", "字符型")) {
        unique_vals <- unique(col[!is.na(col)])
        n_unique <- length(unique_vals)
        
        if (n_unique == 0) {
          "无有效值"
        } else if (n_unique == 1) {
          val_str <- as.character(unique_vals[1])
          if (nchar(val_str) > 20) {
            val_str <- paste0(substr(val_str, 1, 17), "...")
          }
          paste0("单一值: ", val_str)
        } else if (n_unique <= 5) {
          vals_str <- sapply(head(unique_vals, 5), function(x) {
            s <- as.character(x)
            if (nchar(s) > 10) paste0(substr(s, 1, 7), "...") else s
          })
          paste0(n_unique, "个值: ", paste(vals_str, collapse=", "))
        } else {
          paste0(n_unique, "个唯一值")
        }
      } else if (type %in% c("日期型", "日期时间型") && n_valid > 0) {
        date_range <- range(col, na.rm = TRUE)
        paste0(format(date_range[1], "%Y-%m-%d"), " 至 ", 
               format(date_range[2], "%Y-%m-%d"))
      } else if (type == "逻辑型" && n_valid > 0) {
        n_true <- sum(col == TRUE, na.rm = TRUE)
        n_false <- sum(col == FALSE, na.rm = TRUE)
        paste0("TRUE:", n_true, " FALSE:", n_false)
      } else {
        "无法计算"
      }
    }, error = function(e) "计算错误")
    
    # 构建行数据
    row_info <- data.frame(
      变量名 = var,
      类型 = type,
      有效值 = n_valid,
      缺失值 = paste0(n_missing, " (", pct_missing, "%)"),
      取值信息 = value_info,
      stringsAsFactors = FALSE
    )
    
    table1 <- rbind(table1, row_info)
  }
  
  print(table1, row.names = FALSE)
  
  # 表格二：按类型分组的详细信息
  cat("\n表格二：变量详细分析\n")
  cat("-------------------------------------\n")
  
  # 连续型变量
  continuous_vars <- table1$变量名[table1$类型 %in% c("连续型", "整数型")]
  if (length(continuous_vars) > 0) {
    cat("\n--- 连续/整数型变量 ---\n")
    
    table2_cont <- data.frame(
      变量名 = character(),
      均值 = numeric(),
      中位数 = numeric(),
      标准差 = numeric(),
      最小值 = numeric(),
      最大值 = numeric(),
      stringsAsFactors = FALSE
    )
    
    for (var in continuous_vars) {
      col <- data[[var]]
      col_clean <- col[!is.na(col) & is.finite(col)]
      
      if (length(col_clean) == 0) {
        row_stats <- data.frame(
          变量名 = var,
          均值 = NA,
          中位数 = NA,
          标准差 = NA,
          最小值 = NA,
          最大值 = NA,
          stringsAsFactors = FALSE
        )
      } else {
        row_stats <- data.frame(
          变量名 = var,
          均值 = safe_stat(col, mean),
          中位数 = safe_stat(col, median),
          标准差 = safe_stat(col, sd),
          最小值 = safe_stat(col, min),
          最大值 = safe_stat(col, max),
          stringsAsFactors = FALSE
        )
      }
      
      table2_cont <- rbind(table2_cont, row_stats)
    }
    
    print(table2_cont, row.names = FALSE)
  }
  
  # 分类变量（改进显示）
  factor_vars <- table1$变量名[table1$类型 %in% c("因子型", "逻辑型", "字符型")]
  if (length(factor_vars) > 0) {
    cat("\n--- 分类变量 ---\n")
    
    for (var in factor_vars) {
      col <- data[[var]]
      freq_table <- table(col, useNA = "ifany")
      
      cat("\n", var, "的频数分布:\n")
      
      # 创建频数数据框
      freq_df <- data.frame(
        值 = names(freq_table),
        频数 = as.numeric(freq_table),
        比例 = round(as.numeric(freq_table) / sum(freq_table) * 100, 1)
      )
      
      # 处理过长的值
      freq_df$值 <- sapply(freq_df$值, function(x) {
        if (is.na(x) || x == "<NA>") return("(缺失)")
        x_str <- as.character(x)
        if (nchar(x_str) > 20) {
          paste0(substr(x_str, 1, 17), "...")
        } else {
          x_str
        }
      })
      
      # 限制显示数量
      if (nrow(freq_df) > 10) {
        freq_df <- freq_df[order(freq_df$频数, decreasing = TRUE), ]
        print(head(freq_df, 10), row.names = FALSE)
        cat("  ... 还有", nrow(freq_df) - 10, "个类别\n")
      } else {
        print(freq_df, row.names = FALSE)
      }
    }
  }
  
  # 其他类型变量提示
  other_vars <- table1$变量名[!table1$类型 %in% c("连续型", "整数型", "因子型", "逻辑型", "字符型")]
  if (length(other_vars) > 0) {
    cat("\n--- 其他类型变量 ---\n")
    cat("变量: ", paste(other_vars, collapse = ", "), "\n")
    cat("类型: ", paste(unique(table1$类型[table1$变量名 %in% other_vars]), collapse = ", "), "\n")
  }
  
  # 返回不可见的汇总信息
  invisible(list(
    基本信息 = table1,
    数据集 = data_name_str,
    变量数 = length(var_names),
    状态 = "分析完成"
  ))
}

# 函数二：alook - 可视化分析（优化版）
alook <- function(data_name, ...) {
  # 获取数据和变量
  data <- data_name
  data_name_str <- deparse(substitute(data_name))
  
  # 优化：更好的输入验证
  if (!is.data.frame(data)) {
    cat("错误：输入必须是数据框\n")
    cat("当前输入类型：", class(data)[1], "\n")
    cat("建议：使用 data.frame() 或 as.data.frame() 转换数据\n")
    return(invisible(NULL))
  }
  
  # 先执行基础分析
  result <- tryCatch({
    ana(data_name, ...)
  }, error = function(e) {
    cat("基础分析失败：", e$message, "\n")
    cat("无法继续进行可视化分析\n")
    return(NULL)
  })
  
  # 如果基础分析失败，直接返回
  if (is.null(result) || is.null(result$基本信息)) {
    return(invisible(NULL))
  }
  
  # 从ana的返回结果中获取变量名
  var_names <- result$基本信息$变量名
  data <- remove_labels(data)
  
  if (length(var_names) == 0) {
    cat("没有可用于可视化的变量\n")
    return(invisible(NULL))
  }
  
  cat("\n\n========== 可视化分析 ==========\n")
  
  # 检查是否可以绘图
  if (!capabilities("png") && !capabilities("jpeg") && !capabilities("cairo")) {
    warning("当前环境不支持绘图，跳过可视化分析")
    return(invisible(NULL))
  }
  
  # 1. 缺失值比率图（仅当有缺失值时）
  missing_data <- data.frame(
    变量 = var_names,
    缺失比率 = sapply(var_names, function(v) {
      sum(is.na(data[[v]])) / nrow(data) * 100
    })
  ) %>%
    filter(缺失比率 > 0) %>%
    arrange(desc(缺失比率))
  
  if (nrow(missing_data) > 0) {
    tryCatch({
      # 使用渐变色
      n_vars <- nrow(missing_data)
      colors <- colorRampPalette(c("#FF6B6B", "#4ECDC4"))(n_vars)
      
      p_missing <- ggplot(missing_data, aes(x = reorder(变量, 缺失比率), y = 缺失比率)) +
        geom_bar(stat = "identity", fill = colors, width = 0.8) +
        geom_text(aes(label = paste0(round(缺失比率, 1), "%")), 
                  hjust = -0.1, size = 3.5) +
        coord_flip() +
        labs(title = "变量缺失值比率", x = "变量", y = "缺失比率 (%)") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 11),
          axis.text = element_text(size = 10),
          panel.grid.major.y = element_blank()
        ) +
        scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                           limits = c(0, max(missing_data$缺失比率) * 1.15))
      
      print(p_missing)
    }, error = function(e) {
      cat("绘制缺失值图时出错:", e$message, "\n")
    })
  }
  
  # 2. 各变量的分布图
  for (var in var_names) {
    if (!var %in% names(data)) next
    
    col <- data[[var]]
    col_clean <- col[!is.na(col)]
    
    if (length(col_clean) == 0) {
      cat("\n变量", var, "全部为缺失值，跳过绘图\n")
      next
    }
    
    # 数值变量
    if (is.numeric(col)) {
      # 移除无穷值
      col_finite <- col_clean[is.finite(col_clean)]
      
      if (length(col_finite) < 2) {
        cat("\n变量", var, "有效值太少，跳过绘图\n")
        next
      }
      
      # 检查是否所有值相同
      if (length(unique(col_finite)) == 1) {
        cat("\n变量", var, "只有单一值(", unique(col_finite), ")，跳过绘图\n")
        next
      }
      
      # 直方图
      tryCatch({
        # 自动确定bins数量
        n_bins <- min(30, max(5, length(unique(col_finite))))
        
        # 使用渐变色
        p1 <- ggplot(data.frame(x = col_finite), aes(x = x)) +
          geom_histogram(bins = n_bins, aes(fill = after_stat(count)), 
                         color = "white", alpha = 0.9) +
          scale_fill_gradient(low = "#3498DB", high = "#E74C3C", guide = "none") +
          labs(title = paste0(var, " - 频数分布"),
               subtitle = paste0("n=", length(col_finite), ", 均值=", 
                                 round(mean(col_finite), 2), ", 标准差=", 
                                 round(sd(col_finite), 2)),
               x = var, y = "频数") +
          theme_minimal() +
          theme(
            plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
            plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray50")
          )
        
        print(p1)
      }, error = function(e) {
        cat("绘制", var, "的直方图时出错:", e$message, "\n")
      })
      
      # 箱线图（含数据点）
      if (length(col_finite) <= 100) {  # 数据点不太多时显示
        tryCatch({
          p2 <- ggplot(data.frame(x = "", y = col_finite), aes(x = x, y = y)) +
            geom_boxplot(fill = "#FF6B6B", alpha = 0.7, width = 0.5) +
            geom_jitter(width = 0.1, alpha = 0.5, color = "#C44569") +
            labs(title = paste0(var, " - 箱线图"),
                 y = var, x = "") +
            theme_minimal() +
            theme(
              plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank()
            )
          
          print(p2)
        }, error = function(e) {
          cat("绘制", var, "的箱线图时出错:", e$message, "\n")
        })
      }
      
    } else {
      # 分类变量
      tryCatch({
        freq_table <- table(col_clean)
        
        # 如果类别太多，只显示前15个
        if (length(freq_table) > 15) {
          freq_table <- sort(freq_table, decreasing = TRUE)[1:15]
          title_suffix <- " (前15个类别)"
        } else {
          title_suffix <- ""
        }
        
        freq_df <- data.frame(
          类别 = names(freq_table),
          频数 = as.numeric(freq_table)
        ) %>%
          mutate(比例 = round(频数 / sum(频数) * 100, 1))
        
        # 处理过长的类别名
        freq_df$类别显示 <- sapply(freq_df$类别, function(x) {
          if (nchar(as.character(x)) > 20) {
            paste0(substr(as.character(x), 1, 17), "...")
          } else {
            as.character(x)
          }
        })
        
        # 使用彩虹色或渐变色
        n_bars <- nrow(freq_df)
        if (n_bars <= 10) {
          bar_colors <- scales::hue_pal()(n_bars)
        } else {
          bar_colors <- colorRampPalette(c("#4ECDC4", "#45B7D1", "#96CEB4"))(n_bars)
        }
        
        p <- ggplot(freq_df, aes(x = reorder(类别显示, 频数), y = 频数)) +
          geom_bar(stat = "identity", fill = bar_colors, width = 0.8) +
          geom_text(aes(label = paste0(频数, "\n(", 比例, "%)")), 
                    vjust = -0.3, size = 3) +
          labs(title = paste0(var, " - 频数分布", title_suffix),
               subtitle = paste0("共", length(unique(col_clean)), "个类别"),
               x = var, y = "频数") +
          theme_minimal() +
          theme(
            plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
            plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray50"),
            axis.text.x = element_text(angle = 45, hjust = 1, size = 9)
          ) +
          scale_y_continuous(expand = expansion(mult = c(0, 0.15)))
        
        # 如果类别太多，旋转为水平条形图
        if (length(freq_table) > 8 || any(nchar(freq_df$类别显示) > 10)) {
          p <- p + coord_flip() + 
            theme(axis.text.x = element_text(angle = 0, hjust = 1))
        }
        
        print(p)
      }, error = function(e) {
        cat("绘制", var, "的条形图时出错:", e$message, "\n")
      })
    }
  }
  
  invisible(NULL)
}

# 函数三：avar - 批量分析所有变量（优化版）
avar <- function(data_name) {
  # 获取数据
  data <- data_name
  data_name_str <- deparse(substitute(data_name))
  
  # 优化：改进输入验证
  if (!is.data.frame(data)) {
    cat("\n========== 批量变量分析 ==========\n")
    cat("错误：输入必须是数据框，当前类型: ", class(data)[1], "\n")
    cat("建议：使用 data.frame() 或 as.data.frame() 转换数据\n")
    cat("=====================================\n")
    return(invisible(list(
      数据集 = data_name_str,
      状态 = "输入类型错误"
    )))
  }
  
  if (nrow(data) == 0 || ncol(data) == 0) {
    cat("\n========== 批量变量分析 ==========\n")
    cat("数据集: ", data_name_str, "\n")
    cat("数据框为空（", nrow(data), "行 × ", ncol(data), "列）\n")
    cat("建议：检查数据加载过程或数据筛选条件\n")
    cat("=====================================\n")
    return(invisible(list(
      数据集 = data_name_str,
      状态 = "空数据框",
      行数 = nrow(data),
      列数 = ncol(data)
    )))
  }
  
  data <- remove_labels(data)
  all_vars <- names(data)
  
  cat("\n========== 批量变量分析 ==========\n")
  cat("数据集: ", data_name_str, "\n")
  cat("共有", ncol(data), "个变量，", nrow(data), "个观测值\n")
  cat("=====================================\n")
  
  # 创建详细的变量类型表
  cat("\n变量类型详细列表:\n")
  cat("-------------------------------------\n")
  
  var_type_detail <- data.frame(
    变量名 = character(),
    类型 = character(),
    详细类型 = character(),
    stringsAsFactors = FALSE
  )
  
  for (var in all_vars) {
    col <- data[[var]]
    
    # 判断详细类型（增强版）
    type_info <- tryCatch({
      if (is.complex(col)) {
        list(type = "特殊型", detail = "复数")
      } else if (is.list(col)) {
        list(type = "特殊型", detail = "列表列")
      } else if (is.numeric(col) && !is.integer(col)) {
        # 检查特殊值
        n_inf <- sum(is.infinite(col), na.rm = TRUE)
        n_nan <- sum(is.nan(col), na.rm = TRUE)
        if (n_inf > 0 || n_nan > 0) {
          detail_parts <- c()
          if (n_inf > 0) detail_parts <- c(detail_parts, paste0(n_inf, "个Inf"))
          if (n_nan > 0) detail_parts <- c(detail_parts, paste0(n_nan, "个NaN"))
          list(type = "数值型", detail = paste0("连续型(含", paste(detail_parts, collapse=","), ")"))
        } else {
          list(type = "数值型", detail = "连续型数值")
        }
      } else if (is.integer(col)) {
        list(type = "数值型", detail = "整数型")
      } else if (is.factor(col)) {
        list(type = "分类型", detail = paste0("因子(", nlevels(col), "个水平)"))
      } else if (is.logical(col)) {
        n_true <- sum(col == TRUE, na.rm = TRUE)
        n_false <- sum(col == FALSE, na.rm = TRUE)
        n_na <- sum(is.na(col))
        list(type = "分类型", detail = paste0("逻辑型(T:", n_true, " F:", n_false, 
                                           if(n_na > 0) paste0(" NA:", n_na) else "", ")"))
      } else if (is.character(col)) {
        n_unique <- length(unique(col[!is.na(col)]))
        n_empty <- sum(col == "", na.rm = TRUE)
        if (n_empty > 0) {
          list(type = "字符型", detail = paste0("字符(", n_unique, 
                                             "个唯一值,", n_empty, "个空串)"))
        } else {
          list(type = "字符型", detail = paste0("字符(", n_unique, "个唯一值)"))
        }
      } else if (inherits(col, "Date")) {
        list(type = "日期型", detail = "日期")
      } else if (inherits(col, "POSIXt")) {
        list(type = "日期型", detail = "日期时间")
      } else {
        list(type = "其他", detail = paste(class(col), collapse = "/"))
      }
    }, error = function(e) {
      list(type = "未知", detail = "无法识别")
    })
    
    var_type_detail <- rbind(var_type_detail, data.frame(
      变量名 = var,
      类型 = type_info$type,
      详细类型 = type_info$detail,
      stringsAsFactors = FALSE
    ))
  }
  
  # 打印所有变量（如果变量太多，分页显示）
  if (nrow(var_type_detail) > 100) {
    # 超过100个变量时，分页显示
    cat("共", nrow(var_type_detail), "个变量，分页显示：\n\n")
    
    # 按类型分组显示
    for (type_name in unique(var_type_detail$类型)) {
      type_vars <- var_type_detail[var_type_detail$类型 == type_name, ]
      if (nrow(type_vars) > 0) {
        cat("【", type_name, "】(", nrow(type_vars), "个):\n", sep = "")
        print(type_vars, row.names = FALSE)
        cat("\n")
      }
    }
  } else {
    # 100个以内直接显示
    print(var_type_detail, row.names = FALSE)
  }
  
  # 类型汇总统计
  cat("\n\n类型汇总统计:\n")
  cat("-------------------------------------\n")
  
  type_summary <- table(var_type_detail$类型)
  for (type_name in names(type_summary)) {
    count <- type_summary[type_name]
    vars_of_type <- var_type_detail$变量名[var_type_detail$类型 == type_name]
    
    cat("\n", type_name, " (", count, "个):\n", sep = "")
    if (length(vars_of_type) <= 20) {
      # 20个以内直接显示
      cat("  ", paste(vars_of_type, collapse = ", "), "\n")
    } else if (length(vars_of_type) <= 50) {
      # 20-50个分行显示
      for (i in seq(1, length(vars_of_type), by = 10)) {
        end_idx <- min(i + 9, length(vars_of_type))
        cat("  ", paste(vars_of_type[i:end_idx], collapse = ", "), "\n")
      }
    } else {
      # 超过50个的显示前30个和后10个
      cat("  前30个: ", paste(head(vars_of_type, 30), collapse = ", "), "\n")
      cat("  ... 中间省略", length(vars_of_type) - 40, "个变量 ...\n")
      cat("  后10个: ", paste(tail(vars_of_type, 10), collapse = ", "), "\n")
    }
  }
  
  # 缺失值概览
  cat("\n\n缺失值概览:\n")
  cat("-------------------------------------\n")
  
  missing_summary <- data.frame(
    变量名 = character(),
    类型 = character(),
    缺失数 = integer(),
    缺失率 = numeric(),
    stringsAsFactors = FALSE
  )
  
  # 安全计算缺失值
  for (i in seq_along(all_vars)) {
    var <- all_vars[i]
    n_missing <- sum(is.na(data[[var]]))
    if (n_missing > 0) {
      missing_summary <- rbind(missing_summary, data.frame(
        变量名 = var,
        类型 = var_type_detail$类型[i],
        缺失数 = n_missing,
        缺失率 = round(n_missing / nrow(data) * 100, 2),
        stringsAsFactors = FALSE
      ))
    }
  }
  
  if (nrow(missing_summary) > 0) {
    missing_summary <- missing_summary %>% arrange(desc(缺失率))
    
    # 根据缺失变量数量决定显示策略
    if (nrow(missing_summary) <= 30) {
      # 30个以内全部显示
      print(missing_summary, row.names = FALSE)
    } else if (nrow(missing_summary) <= 100) {
      # 30-100个显示高缺失率的和概要
      cat("缺失率 > 20% 的变量:\n")
      high_missing <- missing_summary %>% filter(缺失率 > 20)
      if (nrow(high_missing) > 0) {
        print(high_missing, row.names = FALSE)
      } else {
        cat("  (无)\n")
      }
      
      cat("\n其他缺失情况概要:\n")
      low_missing <- missing_summary %>% filter(缺失率 <= 20)
      cat("  缺失率 10-20%:", sum(low_missing$缺失率 > 10 & low_missing$缺失率 <= 20), "个变量\n")
      cat("  缺失率 5-10%:", sum(low_missing$缺失率 > 5 & low_missing$缺失率 <= 10), "个变量\n")
      cat("  缺失率 1-5%:", sum(low_missing$缺失率 > 1 & low_missing$缺失率 <= 5), "个变量\n")
      cat("  缺失率 <1%:", sum(low_missing$缺失率 <= 1), "个变量\n")
    } else {
      # 超过100个变量有缺失时，分级显示
      cat("缺失情况分级汇总:\n")
      cat("  缺失率 >50%:", sum(missing_summary$缺失率 > 50), "个变量\n")
      cat("  缺失率 20-50%:", sum(missing_summary$缺失率 > 20 & missing_summary$缺失率 <= 50), "个变量\n")
      cat("  缺失率 10-20%:", sum(missing_summary$缺失率 > 10 & missing_summary$缺失率 <= 20), "个变量\n")
      cat("  缺失率 5-10%:", sum(missing_summary$缺失率 > 5 & missing_summary$缺失率 <= 10), "个变量\n")
      cat("  缺失率 1-5%:", sum(missing_summary$缺失率 > 1 & missing_summary$缺失率 <= 5), "个变量\n")
      cat("  缺失率 <1%:", sum(missing_summary$缺失率 <= 1), "个变量\n")
      
      cat("\n缺失率最高的20个变量:\n")
      print(head(missing_summary, 20), row.names = FALSE)
    }
    
    # 缺失值模式汇总
    total_missing <- sum(missing_summary$缺失数)
    total_cells <- nrow(data) * ncol(data)
    overall_missing_rate <- round(total_missing / total_cells * 100, 2)
    
    cat("\n总体缺失率: ", overall_missing_rate, "%", 
        " (", total_missing, "/", total_cells, ")\n", sep = "")
  } else {
    cat("数据集中没有缺失值\n")
  }
  
  # 数据质量建议
  cat("\n\n数据质量建议:\n")
  cat("-------------------------------------\n")
  
  # 高缺失率变量
  high_missing <- missing_summary %>% filter(缺失率 > 50)
  if (nrow(high_missing) > 0) {
    cat("• 以下变量缺失率超过50%，建议检查数据收集过程:\n")
    if (nrow(high_missing) <= 20) {
      cat("  ", paste(high_missing$变量名, collapse = ", "), "\n")
    } else {
      cat("  共", nrow(high_missing), "个变量，包括: ", 
          paste(head(high_missing$变量名, 10), collapse = ", "), 
          " ... 等\n")
    }
  }
  
  # 单一值变量
  single_value_vars <- c()
  for (var in all_vars) {
    if (length(unique(data[[var]][!is.na(data[[var]])])) == 1) {
      single_value_vars <- c(single_value_vars, var)
    }
  }
  
  if (length(single_value_vars) > 0) {
    cat("• 以下变量只有单一值，可能需要从分析中排除:\n")
    if (length(single_value_vars) <= 20) {
      cat("  ", paste(single_value_vars, collapse = ", "), "\n")
    } else {
      cat("  共", length(single_value_vars), "个变量，包括: ", 
          paste(head(single_value_vars, 10), collapse = ", "), 
          " ... 等\n")
    }
  }
  
  # 数据质量得分
  quality_score <- 100
  if (nrow(missing_summary) > 0) {
    avg_missing <- mean(missing_summary$缺失率)
    quality_score <- quality_score - min(avg_missing * 2, 50)
  }
  quality_score <- quality_score - length(single_value_vars) * 0.5
  quality_score <- max(quality_score, 0)
  
  cat("\n数据质量综合评分: ", round(quality_score), "/100\n", sep = "")
  if (quality_score >= 90) {
    cat("评价: 优秀 - 数据质量很高\n")
  } else if (quality_score >= 75) {
    cat("评价: 良好 - 数据质量较好\n")
  } else if (quality_score >= 60) {
    cat("评价: 中等 - 建议进行数据清理\n")
  } else {
    cat("评价: 较差 - 强烈建议数据预处理\n")
  }
  
  # 返回变量类型详情（不可见）
  invisible(list(
    变量类型详情 = var_type_detail,
    缺失值汇总 = missing_summary,
    数据维度 = c(nrow = nrow(data), ncol = ncol(data)),
    单一值变量 = single_value_vars,
    状态 = "分析完成"
  ))
}

# 加载成功提示
message("加载完成，ana工具包!!　发射----->!!!!
　 ＿∧_∧＿＿＿/／
≡(_ ( ･∀･)＿＿( 三三三三三● ● ● ● ● ● ● ->
　　( ニつノ｜｜　＼
　　ヽ_⌒|　｜｜
　　し_(＿)   ｜｜
　　　　　　¯¯¯")

cat("\n可用函数:\n")
cat("  ana()   - 基础分析\n")
cat("  alook() - 可视化分析\n") 
cat("  avar()  - 所有变量分类\n")