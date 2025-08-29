# Aim: init R project dir structure
# Usage: > source("init_project.R") to create a clean R project structure, with custom proj name.
# v0.1

init_project <- function(project_name = "my_project") {
  dirs <- c(
    "data/raw",
    "data/processed",
    "scripts",
    "R",
    "output"
  )
  
  # Create main folder
  if (!dir.exists(project_name)) {
    dir.create(project_name)
  }
  
  # Create subfolders
  for (d in dirs) {
    dir.create(file.path(project_name, d), recursive = TRUE, showWarnings = FALSE)
  }
  
  # Create README
  readme_path <- file.path(project_name, "README.md")
  if (!file.exists(readme_path)) {
    cat("# ", project_name, "\n\n",
        "## Project structure\n",
        "- data/raw: raw input data (DO NOT MODIFY)\n",
        "- data/processed: cleaned or derived datasets\n",
        "- scripts/: stepwise R scripts (01_load.R, 02_analysis.R, ...)\n",
        "- R/: helper functions/utilities\n",
        "- output/: tables, plots, Rmd\n",
        file = readme_path, sep = "")
  }

  # Create template script
  script_path <- file.path(project_name, "scripts/01_load.R")
  if (!file.exists(script_path)) {
    cat("# Example script: Load and clean data\n\n",
        "library(here)\n\n",
        "# Load raw data\n",
        "# df <- read.csv(here::here('data/raw/example.csv'))\n\n",
        "# Clean / transform data\n",
        "# df_clean <- df[complete.cases(df), ]\n\n",
        "# Save processed data\n",
        "# write.csv(df_clean, here::here('data/processed/cleaned.csv'), row.names = FALSE)\n",
        file = script_path, sep = "")
  }
  
  # Create .Rproj file (optional if you use RStudio)
  rproj_path <- file.path(project_name, paste0(project_name, ".Rproj"))
  if (!file.exists(rproj_path)) {
    cat("Version: 1.0\n\nRestoreWorkspace: No\nSaveWorkspace: No\nAlwaysSaveHistory: Default\n\n",
        "EnableCodeIndexing: Yes\nUseSpacesForTab: Yes\nNumSpacesForTab: 2\nEncoding: UTF-8\n\n",
        "RnwWeave: Sweave\nLaTeX: pdfLaTeX\n",
        file = rproj_path, sep = "")
  }
  
  message("* Project initialized at: ", normalizePath(project_name))
}

# Run it once:
# init_project("my_project")

# 自动提示输入项目名
project_name <- readline(prompt = "Please input project name( Default: my_project):")
if (project_name == "") project_name <- "my_project"

init_project(project_name)