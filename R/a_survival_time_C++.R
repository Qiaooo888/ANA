# =====================================================
# 优化版本2：Rcpp实现（速度提升10-20倍）
# =====================================================

# 需要安装：install.packages("Rcpp")
library(Rcpp)

# C++代码（内联编译）
cppFunction('
NumericVector calculate_survival_cpp(NumericVector time, 
                                     NumericVector event, 
                                     IntegerVector id) {
  int n = time.size();
  NumericVector survival_time(n, NA_REAL);
  
  // 获取唯一ID
  std::map<int, std::vector<int>> id_indices;
  for(int i = 0; i < n; i++) {
    id_indices[id[i]].push_back(i);
  }
  
  // 处理每个ID
  for(auto& pair : id_indices) {
    std::vector<int>& indices = pair.second;
    
    // 找到第一个有效时间
    double first_time = NA_REAL;
    for(int idx : indices) {
      if(!NumericVector::is_na(time[idx])) {
        if(NumericVector::is_na(first_time) || time[idx] < first_time) {
          first_time = time[idx];
        }
      }
    }
    
    if(NumericVector::is_na(first_time)) continue;
    
    // 找到第一次事件
    int first_event_idx = -1;
    double event_time = NA_REAL;
    for(int i = 0; i < indices.size(); i++) {
      int idx = indices[i];
      if(!NumericVector::is_na(time[idx]) && 
         !NumericVector::is_na(event[idx]) && 
         event[idx] == 1) {
        first_event_idx = i;
        event_time = time[idx];
        break;
      }
    }
    
    // 计算生存时间
    double final_survival_time = NumericVector::is_na(event_time) ? 
                                 NA_REAL : event_time - first_time;
    
    for(int i = 0; i < indices.size(); i++) {
      int idx = indices[i];
      if(!NumericVector::is_na(time[idx]) && 
         !NumericVector::is_na(event[idx])) {
        if(first_event_idx == -1) {
          // 无事件
          survival_time[idx] = time[idx] - first_time;
        } else {
          // 有事件
          if(i < first_event_idx) {
            survival_time[idx] = time[idx] - first_time;
          } else {
            survival_time[idx] = final_survival_time;
          }
        }
      }
    }
  }
  
  return survival_time;
}
')

a_survival_time_rcpp <- function(data, id_var, time = "", event = "") {
  # 参数验证
  if(missing(data) || missing(id_var) || time == "" || event == "") {
    stop("缺少必要参数")
  }
  
  # 准备数据
  df <- data.frame(data)
  df$original_order <- seq_len(nrow(df))
  
  # 排序
  df <- df[order(df[[id_var]], df[[time]]), ]
  
  # 转换为数值
  time_vec <- as.numeric(df[[time]])
  event_vec <- as.numeric(df[[event]])
  id_vec <- as.integer(factor(df[[id_var]]))
  
  # 调用C++函数
  df$Survival_time <- calculate_survival_cpp(time_vec, event_vec, id_vec)
  
  # 恢复原始顺序
  df <- df[order(df$original_order), ]
  df$original_order <- NULL
  
  return(df)
}
