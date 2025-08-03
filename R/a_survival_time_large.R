# =====================================================
# 优化版本3：并行处理（适合超大数据集）
# =====================================================

library(parallel)
library(foreach)
library(doParallel)

a_survival_time_parallel <- function(data, id_var, time = "", event = "", 
                                     n_cores = NULL) {
  
  # 确定核心数
  if(is.null(n_cores)) {
    n_cores <- min(detectCores() - 1, 4)
  }
  
  # 按ID分组
  unique_ids <- unique(data[[id_var]])
  n_ids <- length(unique_ids)
  
  # 如果ID数量少，不值得并行
  if(n_ids < 100) {
    return(a_survival_time_improved(data, id_var, time, event, verbose = FALSE))
  }
  
  # 创建集群
  cl <- makeCluster(n_cores)
  registerDoParallel(cl)
  
  # 分割数据
  id_chunks <- split(unique_ids, cut(seq_along(unique_ids), n_cores, labels = FALSE))
  
  # 并行处理
  results <- foreach(chunk_ids = id_chunks, .combine = rbind) %dopar% {
    chunk_data <- data[data[[id_var]] %in% chunk_ids, ]
    # 在每个核心上运行原始函数
    a_survival_time_improved(chunk_data, id_var, time, event, 
                             check_order = FALSE, verbose = FALSE)
  }
  
  # 关闭集群
  stopCluster(cl)
  
  return(results)
}
