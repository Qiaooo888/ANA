# ana包基础用法示例

# 加载包
source("../ana.R")

# 示例1：基础分析
cat("=== 示例1：iris数据集基础分析 ===\n")
ana(iris, "Sepal.Length", "Species")

# 示例2：自动分析
cat("\n=== 示例2：自动分析所有变量 ===\n")
ana(mtcars)

# 示例3：可视化分析
cat("\n=== 示例3：可视化分析 ===\n")
alook(iris, "Sepal.Length", "Petal.Width")

# 示例4：批量分析
cat("\n=== 示例4：批量分析 ===\n")
avar(iris)