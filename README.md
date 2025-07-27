# ana包 - 数据分析可视化工具包 📊 / ana Package - Data Analysis and Visualization Toolkit 📊

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/ana)
[![License](https://img.shields.io/badge/license-GPL--3-green.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R Version](https://img.shields.io/badge/R-%3E%3D%203.5.0-lightgrey.svg)](https://www.r-project.org/)

## 🚀 简介 / Introduction

**中文：** `ana` 是一个强大的R数据分析和可视化工具包，专为快速探索性数据分析而设计。它提供了简洁易用的函数，帮助您快速了解数据集的基本特征、变量分布和数据质量。

**English:** `ana` is a powerful R data analysis and visualization toolkit designed specifically for rapid exploratory data analysis. It provides concise and user-friendly functions to help you quickly understand the basic characteristics, variable distributions, and data quality of your datasets.

### ✨ 主要特性 / Key Features

| 中文 | English |
|------|---------|
| **自动化分析**：智能识别变量类型，自动选择合适的分析方法 | **Automated Analysis**: Intelligently identifies variable types and automatically selects appropriate analysis methods |
| **可视化输出**：生成美观的统计图表，直观展示数据分布 | **Visual Output**: Generates beautiful statistical charts that intuitively display data distributions |
| **批量处理**：支持同时分析多个变量，提高工作效率 | **Batch Processing**: Supports simultaneous analysis of multiple variables for improved efficiency |
| **数据质量检查**：自动检测缺失值、异常值和数据类型问题 | **Data Quality Check**: Automatically detects missing values, outliers, and data type issues |
| **中文友好**：完美支持中文输出和显示 | **Chinese-Friendly**: Perfect support for Chinese output and display |

## 📦 安装 / Installation

### 从GitHub安装（推荐）/ Install from GitHub (Recommended)

```r
# 安装 devtools（如果尚未安装）/ Install devtools (if not already installed)
install.packages("devtools")

# 从 GitHub 安装 ana 包 / Install ana package from GitHub
devtools::install_github("Qiaooo888/ANA")
```

### 手动安装 / Manual Installation

```r
# 1. 下载源代码 / Download source code
# 2. 在R中运行 / Run in R
source("ana.R") ### <- <- <- <- <- <- <- <- ━━╋══════➢ ""号中填入R文件的保存位置 / Enter the save location of the R file in ""
```

## 🎯 快速开始 / Quick Start

```r
# 加载包（会自动安装并加载依赖包）/ Load package (will automatically install and load dependencies)
library(ana)

# 示例数据 / Example data
data(mtcars)

# 基础分析 - 分析所有变量 / Basic analysis - analyze all variables
ana(mtcars)

# 分析指定变量 / Analyze specific variables
ana(mtcars, "mpg", "cyl", "hp")

# 可视化分析 / Visual analysis
alook(mtcars, "mpg", "cyl")

# 批量变量分类 / Batch variable classification
avar(mtcars)
```

## 📖 函数说明 / Function Documentation

### 1. `ana()` - 基础分析 / Basic Analysis

**中文：** 对数据框进行基础统计分析，自动识别变量类型并提供相应的统计信息。

**English:** Performs basic statistical analysis on data frames, automatically identifies variable types and provides corresponding statistical information.

```r
ana(data, ...)
```

**参数 / Parameters:**
- `data`：数据框 / Data frame
- `...`：要分析的变量名（可选，默认分析前10个适合的变量）/ Variable names to analyze (optional, defaults to first 10 suitable variables)

**输出 / Output:**
- 变量基本信息表（类型、有效值、缺失值、取值范围）/ Basic variable information table (type, valid values, missing values, value range)
- 连续变量统计量（均值、中位数、标准差等）/ Continuous variable statistics (mean, median, standard deviation, etc.)
- 分类变量频数分布 / Categorical variable frequency distribution

### 2. `alook()` - 可视化分析 / Visual Analysis

**中文：** 在基础分析的基础上，生成数据分布的可视化图表。

**English:** Based on basic analysis, generates visualizations of data distributions.

```r
alook(data, ...)
```

**特性 / Features:**
- 自动为不同类型变量选择合适的图表 / Automatically selects appropriate charts for different variable types
- 连续变量：直方图、箱线图 / Continuous variables: Histograms, box plots
- 分类变量：条形图 / Categorical variables: Bar charts
- 缺失值比率图 / Missing value ratio charts

### 3. `avar()` - 批量变量分类 / Batch Variable Classification

**中文：** 对数据集中所有变量进行分类和汇总，提供数据质量评估。

**English:** Classifies and summarizes all variables in the dataset, providing data quality assessment.

```r
avar(data)
```

**输出 / Output:**
- 所有变量的详细类型列表 / Detailed type list of all variables
- 类型汇总统计 / Type summary statistics
- 缺失值概览 / Missing value overview
- 数据质量评分和建议 / Data quality score and recommendations

## 🌟 使用示例 / Usage Examples

### 示例1：探索鸢尾花数据 / Example 1: Exploring Iris Data

```r
library(ana)

# 加载数据 / Load data
data(iris)

# 基础分析 / Basic analysis
ana(iris)

# 可视化分析特定变量 / Visual analysis of specific variables
alook(iris, "Sepal.Length", "Species")

# 查看所有变量分类 / View all variable classifications
avar(iris)
```

### 示例2：处理包含缺失值的数据 / Example 2: Handling Data with Missing Values

```r
# 创建包含缺失值的示例数据 / Create sample data with missing values
test_data <- data.frame(
  x = c(1:8, NA, NA),
  y = c(NA, 2:10),
  group = factor(c("A", "B", "A", "B", NA, "A", "B", "A", "B", "A"))
)

# 分析会自动处理缺失值 / Analysis automatically handles missing values
ana(test_data)
alook(test_data)
```

### 示例3：大型数据集分析 / Example 3: Large Dataset Analysis

```r
# 对于大型数据集，可以选择性分析 / For large datasets, selective analysis is possible
library(ana)

# 假设有一个1000列的大数据集 / Assume a large dataset with 1000 columns
# big_data <- your_large_dataset

# 只分析特定变量 / Analyze only specific variables
# ana(big_data, "var1", "var2", "var3")

# 查看所有变量的分类（会自动分页显示）/ View classification of all variables (automatically paginated)
# avar(big_data)
```

## 🛠️ 高级功能 / Advanced Features

### 自动处理特殊数据类型 / Automatic Handling of Special Data Types

| 中文 | English |
|------|---------|
| **Haven标签数据**：自动清除SPSS/Stata/SAS导入的标签 | **Haven labeled data**: Automatically clears labels imported from SPSS/Stata/SAS |
| **日期时间**：正确识别和分析日期型变量 | **Date-time**: Correctly identifies and analyzes date variables |
| **复杂数据类型**：处理列表列、复数等特殊类型 | **Complex data types**: Handles list columns, complex numbers, and other special types |

### 数据质量评估 / Data Quality Assessment

**中文：** `avar()` 函数提供综合的数据质量评分（0-100分），考虑因素包括：
- 缺失值比例
- 单一值变量数量
- 数据完整性

**English:** The `avar()` function provides a comprehensive data quality score (0-100), considering factors including:
- Missing value ratio
- Number of single-value variables
- Data completeness

## 📋 依赖包 / Dependencies

**中文：** ana包会自动安装和加载以下依赖：

**English:** The ana package will automatically install and load the following dependencies:

- `haven`：读取SPSS/Stata/SAS文件 / Read SPSS/Stata/SAS files
- `ggplot2`：数据可视化 / Data visualization
- `dplyr`：数据处理 / Data processing
- `scales`：图表刻度 / Chart scales
- `knitr`：报告生成 / Report generation
- `rmarkdown`：文档输出 / Document output

## 🤝 贡献 / Contributing

**中文：** 欢迎提交问题报告和功能建议！

**English:** Welcome to submit issue reports and feature suggestions!

1. Fork 本仓库 / Fork this repository
2. 创建您的特性分支 / Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 / Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 / Push to the branch (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request / Open a Pull Request

## 📄 许可证 / License

**中文：** 本项目采用 GPL-3 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

**English:** This project is licensed under the GPL-3 License - see the [LICENSE](LICENSE) file for details

## 👥 作者 / Authors

- **Qiaooo888** - *Initial work* - [Qiaooo888](https://github.com/yourusername)

## 🙏 致谢 / Acknowledgments

**中文：** 感谢所有为这个项目做出贡献的人！

**English:** Thanks to everyone who has contributed to this project!

---

**加载完成，ana工具包!! 发射----->!!!!**  
**Loading complete, ana toolkit!! Launch----->!!!!**

```
　 ＿∧_∧＿＿＿/／
≡(_ ( ･∀･)＿＿( 三三三三三● ● ● ● ● ● ● ->
　　( ニつノ｜｜　＼
　　ヽ_⌒|　｜｜
　　し_(＿)   ｜｜
　　　　　　¯¯¯
```