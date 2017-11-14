Sys.setenv(RSTUDIO_PANDOC="/usr/lib/rstudio-server/bin/pandoc")
rmarkdown::render('lenta_report.Rmd', output_dir = 'output', output_format = "html_document")