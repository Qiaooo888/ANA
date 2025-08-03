# =====================================================
# 优化版本4：内存优化版（适合内存受限环境）
# =====================================================

a_survival_time_memory <- function(data, id_var, time = "", event = "") {
  
  # 使用整数索引代替字符串ID（节省内存）
  if(is.character(data[[id_var]]) || is.factor(data[[id_var]])) {
    id_factor <- factor(data[[id_var]])
    data$ID_int <- as.integer(id_factor)
    id_levels <- levels(id_factor)
    use_int_id <- TRUE
  } else {
    data$ID_int <- data[[id_var]]
    use_int_id <- FALSE
  }
  
  # 只保留必要的列（减少内存占用）
  essential_cols <- c("ID_int", time, event)
  other_cols <- setdiff(names(data), essential_cols)
  
  # 分离数据
  work_data <- data[, essential_cols]
  other_data <- data[, other_cols, drop = FALSE]
  
  # 使用更紧凑的数据类型
  work_data[[time]] <- as.single(as.numeric(work_data[[time]]))  # float32
  work_data[[event]] <- as.integer(work_data[[event]])  # int32
  
  # 添加行号
  work_data$row_id <- seq_len(nrow(work_data))
  
  # 排序（使用radix sort，更快）
  work_data <- work_data[order(work_data$ID_int, work_data[[time]], 
                               method = "radix"), ]
  
  # 预分配结果向量
  survival_time <- numeric(nrow(work_data))
  
  # 处理每个ID（避免创建子集）
  unique_ids <- unique(work_data$ID_int)
  
  for(id in unique_ids) {
    id_mask <- work_data$ID_int == id
    id_indices <- which(id_mask)
    
    if(length(id_indices) == 0) next
    
    # 直接在原数据上操作，避免复制
    id_times <- work_data[[time]][id_indices]
    id_events <- work_data[[event]][id_indices]
    
    # 计算生存时间
    valid_mask <- !is.na(id_times) & !is.na(id_events)
    if(any(valid_mask)) {
      first_time <- min(id_times[!is.na(id_times)])
      
      event_idx <- which(valid_mask & id_events == 1)[1]
      if(!is.na(event_idx)) {
        final_time <- id_times[event_idx] - first_time
        for(i in seq_along(id_indices)) {
          if(valid_mask[i]) {
            survival_time[id_indices[i]] <- if(i < event_idx) {
              id_times[i] - first_time
            } else {
              final_time
            }
          } else {
            survival_time[id_indices[i]] <- NA
          }
        }
      } else {
        survival_time[id_indices[valid_mask]] <- 
          id_times[valid_mask] - first_time
      }
    } else {
      survival_time[id_indices] <- NA
    }
  }
  
  # 添加结果
  work_data$Survival_time <- survival_time
  
  # 恢复原始顺序
  work_data <- work_data[order(work_data$row_id), ]
  
  # 合并回原始数据
  result <- cbind(other_data, Survival_time = work_data$Survival_time)
  
  return(result)
}
