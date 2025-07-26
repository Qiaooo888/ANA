.onAttach_with_pacman <- function(libname, pkgname) {
  # 首先确保 pacman 包已安装
  if (!requireNamespace("pacman", quietly = TRUE)) {
    utils::install.packages("pacman")
  }
  
  # 使用 pacman 自动安装并载入所有依赖
  pacman::p_load(haven, ggplot2, dplyr, scales, knitr, rmarkdown)
  
  packageStartupMessage(paste(pkgname, "及所有依赖包已载入！"))
}