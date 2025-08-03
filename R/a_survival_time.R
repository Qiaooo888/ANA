# 改进版的生存时间计算函数
a_survival_time_improved <- function(data, id_var, time = "", event = "", 
                                     check_order = TRUE, verbose = TRUE,
                                     handle_negative_time = TRUE) {
  
  # 1. 参数验证
  if(missing(data) || missing(id_var)) {
    stop("请提供数据框和个体变量名")
  }
  
  if(!is.data.frame(data)) {
    stop("data参数必须是数据框")
  }
  
  if(nrow(data) == 0) {
    warning("数据框为空")
    return(data)
  }
  
  if(time == "" || event == "") {
    stop("请在time和event参数中指定时间变量和结局变量名")
  }
  
  # 检查变量是否存在
  vars_to_check <- c(id_var, time, event)
  missing_vars <- vars_to_check[!vars_to_check %in% names(data)]
  if(length(missing_vars) > 0) {
    stop(paste0("数据框中不存在以下变量：", paste(missing_vars, collapse = ", ")))
  }
  
  # 2. 创建工作数据框副本
  df <- data.frame(data, stringsAsFactors = FALSE)
  
  # 保存原始列名和顺序
  original_names <- names(df)
  
  # 重命名列以便处理（避免特殊字符问题）
  names(df)[names(df) == id_var] <- "ID"
  names(df)[names(df) == time] <- "time"
  names(df)[names(df) == event] <- "event"
  
  # 3. 数据类型转换和验证
  # ID可以保持原始类型（字符、数值或因子）
  
  # 时间变量转换
  df$time <- suppressWarnings(as.numeric(df$time))
  time_na <- sum(is.na(df$time))
  if(time_na > 0 && verbose) {
    message(paste0("警告：时间变量'", time, "'存在", time_na, "个缺失值或无法转换为数值"))
  }
  
  # 检查负时间值
  if(handle_negative_time && any(df$time < 0, na.rm = TRUE)) {
    negative_count <- sum(df$time < 0, na.rm = TRUE)
    if(verbose) {
      message(paste0("注意：发现", negative_count, "个负时间值"))
    }
  }
  
  # 事件变量转换和验证
  df$event <- suppressWarnings(as.numeric(df$event))
  event_na <- sum(is.na(df$event))
  if(event_na > 0 && verbose) {
    message(paste0("警告：结局变量'", event, "'存在", event_na, "个缺失值或无法转换为数值"))
  }
  
  # 检查event的取值
  unique_events <- unique(df$event[!is.na(df$event)])
  if(length(unique_events) > 0) {
    if(!all(unique_events %in% c(0, 1))) {
      if(verbose) {
        message(paste0("注意：结局变量包含非0/1的值：", 
                       paste(setdiff(unique_events, c(0, 1)), collapse = ", ")))
      }
    }
  }
  
  # 4. 添加行号以保持原始顺序
  df$original_order <- seq_len(nrow(df))
  
  # 5. 按ID和time排序
  df <- df[order(df$ID, df$time, na.last = TRUE), ]
  
  # 6. 时间顺序检查（可选）
  if(check_order) {
    check_time_order(df, verbose)
  }
  
  # 7. 初始化Survival_time列
  df$Survival_time <- NA_real_
  
  # 8. 向量化计算（提高性能）
  df <- calculate_survival_vectorized(df, verbose)
  
  # 9. 恢复原始顺序
  df <- df[order(df$original_order), ]
  df$original_order <- NULL
  
  # 10. 恢复原始列名
  names(df)[names(df) == "ID"] <- id_var
  names(df)[names(df) == "time"] <- time
  names(df)[names(df) == "event"] <- event
  
  return(df)
}

# 辅助函数：检查时间顺序
check_time_order <- function(df, verbose) {
  problematic_ids <- character()
  
  unique_ids <- unique(df$ID)
  for(id in unique_ids) {
    id_rows <- which(df$ID == id)
    times <- df$time[id_rows]
    valid_times <- times[!is.na(times)]
    
    if(length(valid_times) > 1) {
      if(any(diff(valid_times) < 0)) {
        problematic_ids <- c(problematic_ids, as.character(id))
      }
    }
  }
  
  if(length(problematic_ids) > 0 && verbose) {
    message(paste0("警告：以下ID存在时间顺序问题（时间倒退）：",
                   paste(head(problematic_ids, 10), collapse = ", "),
                   ifelse(length(problematic_ids) > 10, "...", "")))
  }
}

# 向量化计算生存时间
calculate_survival_vectorized <- function(df, verbose) {
  unique_ids <- unique(df$ID)
  
  # 使用向量化操作处理每个ID
  for(id in unique_ids) {
    id_mask <- df$ID == id
    id_rows <- which(id_mask)
    
    if(length(id_rows) == 0) next
    
    # 获取有效时间
    id_times <- df$time[id_rows]
    id_events <- df$event[id_rows]
    
    # 找到非NA的时间
    valid_time_mask <- !is.na(id_times)
    valid_times <- id_times[valid_time_mask]
    
    if(length(valid_times) == 0) {
      # 所有时间都是NA
      next
    }
    
    first_time <- min(valid_times)
    
    # 找到第一次事件发生
    event_mask <- !is.na(id_events) & id_events == 1 & !is.na(id_times)
    first_event_idx <- which(event_mask)[1]
    
    if(!is.na(first_event_idx)) {
      # 有事件发生
      event_time <- id_times[first_event_idx]
      final_survival_time <- event_time - first_time
      
      # 向量化赋值
      for(i in seq_along(id_rows)) {
        row_idx <- id_rows[i]
        if(!is.na(id_times[i]) && !is.na(id_events[i])) {
          if(i < first_event_idx) {
            df$Survival_time[row_idx] <- id_times[i] - first_time
          } else {
            df$Survival_time[row_idx] <- final_survival_time
          }
        }
      }
    } else {
      # 无事件发生，计算删失时间
      # 需要同时检查时间和事件都不是NA
      valid_mask <- valid_time_mask & !is.na(id_events)
      valid_indices <- id_rows[valid_mask]
      df$Survival_time[valid_indices] <- id_times[valid_mask] - first_time
    }
  }
  
  return(df)
}