# ana包 - 数据分析可视化工具包 📊

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/ana)
[![License](https://img.shields.io/badge/license-GPL--3-green.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R Version](https://img.shields.io/badge/R-%3E%3D%203.5.0-lightgrey.svg)](https://www.r-project.org/)

## 🚀 简介

`ana` 是一个强大的R数据分析和可视化工具包，专为快速探索性数据分析而设计。它提供了简洁易用的函数，帮助您快速了解数据集的基本特征、变量分布和数据质量。

### ✨ 主要特性

- **自动化分析**：智能识别变量类型，自动选择合适的分析方法
- **可视化输出**：生成美观的统计图表，直观展示数据分布
- **批量处理**：支持同时分析多个变量，提高工作效率
- **数据质量检查**：自动检测缺失值、异常值和数据类型问题
- **中文友好**：完美支持中文输出和显示

## 📦 安装

### 从GitHub安装（推荐）

```r
# 安装 devtools（如果尚未安装）
install.packages("devtools")

# 从 GitHub 安装 ana 包
devtools::install_github("Qiaooo888/ANA")
```

### 手动安装

```r
# 1. 下载源代码
# 2. 在R中运行
source("ana.R") ### <- <- <- <- <- <- <- <- ━━╋══════➢ ""号中填入R文件的保存位置
```

## 🎯 快速开始

```r
# 加载包（会自动安装并加载依赖包）
library(ana)

# 示例数据
data(mtcars)

# 基础分析 - 分析所有变量
ana(mtcars)

# 分析指定变量
ana(mtcars, "mpg", "cyl", "hp")

# 可视化分析
alook(mtcars, "mpg", "cyl")

# 批量变量分类
avar(mtcars)
```

## 📖 函数说明

### 1. `ana()` - 基础分析

对数据框进行基础统计分析，自动识别变量类型并提供相应的统计信息。

```r
ana(data, ...)
```

**参数：**
- `data`：数据框
- `...`：要分析的变量名（可选，默认分析前10个适合的变量）

**输出：**
- 变量基本信息表（类型、有效值、缺失值、取值范围）
- 连续变量统计量（均值、中位数、标准差等）
- 分类变量频数分布

### 2. `alook()` - 可视化分析

在基础分析的基础上，生成数据分布的可视化图表。

```r
alook(data, ...)
```

**特性：**
- 自动为不同类型变量选择合适的图表
- 连续变量：直方图、箱线图
- 分类变量：条形图
- 缺失值比率图

### 3. `avar()` - 批量变量分类

对数据集中所有变量进行分类和汇总，提供数据质量评估。

```r
avar(data)
```

**输出：**
- 所有变量的详细类型列表
- 类型汇总统计
- 缺失值概览
- 数据质量评分和建议

## 🌟 使用示例

### 示例1：探索鸢尾花数据

```r
library(ana)

# 加载数据
data(iris)

# 基础分析
ana(iris)

# 可视化分析特定变量
alook(iris, "Sepal.Length", "Species")

# 查看所有变量分类
avar(iris)
```

### 示例2：处理包含缺失值的数据

```r
# 创建包含缺失值的示例数据
test_data <- data.frame(
  x = c(1:8, NA, NA),
  y = c(NA, 2:10),
  group = factor(c("A", "B", "A", "B", NA, "A", "B", "A", "B", "A"))
)

# 分析会自动处理缺失值
ana(test_data)
alook(test_data)
```

### 示例3：大型数据集分析

```r
# 对于大型数据集，可以选择性分析
library(ana)

# 假设有一个1000列的大数据集
# big_data <- your_large_dataset

# 只分析特定变量
# ana(big_data, "var1", "var2", "var3")

# 查看所有变量的分类（会自动分页显示）
# avar(big_data)
```

## 🛠️ 高级功能

### 自动处理特殊数据类型

- **Haven标签数据**：自动清除SPSS/Stata/SAS导入的标签
- **日期时间**：正确识别和分析日期型变量
- **复杂数据类型**：处理列表列、复数等特殊类型

### 数据质量评估

`avar()` 函数提供综合的数据质量评分（0-100分），考虑因素包括：
- 缺失值比例
- 单一值变量数量
- 数据完整性

## 📋 依赖包

ana包会自动安装和加载以下依赖：
- `haven`：读取SPSS/Stata/SAS文件
- `ggplot2`：数据可视化
- `dplyr`：数据处理
- `scales`：图表刻度
- `knitr`：报告生成
- `rmarkdown`：文档输出

## 🤝 贡献

欢迎提交问题报告和功能建议！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 📄 许可证

本项目采用 GPL-3 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👥 作者

- **Qiaooo888** - *Initial work* - [Qiaooo888](https://github.com/yourusername)

## 🙏 致谢

感谢所有为这个项目做出贡献的人！

---

**加载完成，ana工具包!! 发射----->!!!!**
```
　 ＿∧_∧＿＿＿/／
≡(_ ( ･∀･)＿＿( 三三三三三● ● ● ● ● ● ● ->
　　( ニつノ｜｜　＼
　　ヽ_⌒|　｜｜
　　し_(＿)   ｜｜
　　　　　　¯¯¯
```