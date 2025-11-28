# Excel Utilities for R Scripts
# Collection of functions for creating formatted Excel files
#

library(openxlsx)

# Function to set Excel worksheet zoom level
# https://stackoverflow.com/questions/74227453/set-excel-worksheet-zoom-level-from-r-openxlsx
#
set_zoom <- function(wb, sheet_index, zoom_level) {
  sV <- wb$worksheets[[sheet_index]]$sheetViews
  wb$worksheets[[sheet_index]]$sheetViews <- gsub('(?<=zoomScale=")[0-9]+', zoom_level, sV, perl = TRUE)
  return(wb)
}

# Function to calculate smart column widths based on data content
#
smart_col_widths <- function(data, base_multiplier = 1.2) {
  widths <- c()

  for (i in 1:ncol(data)) {
    col_name <- names(data)[i]
    col_data <- data[[i]]

    # Header width
    header_len <- nchar(col_name)

    # Content analysis
    if (is.numeric(col_data)) {
      # For numbers, consider formatting
      max_content <- max(nchar(format(col_data, digits = 2, nsmall = 0)), na.rm = TRUE)
    } else if (is.factor(col_data)) {
      # For factors, check all levels
      max_content <- max(nchar(levels(col_data)), na.rm = TRUE)
    } else {
      # For characters
      max_content <- max(nchar(as.character(col_data)), na.rm = TRUE)
    }

    # Take max and apply multiplier
    optimal_width <- max(header_len, max_content) * base_multiplier

    # Set reasonable bounds
    optimal_width <- pmax(8, pmin(50, optimal_width))

    widths <- c(widths, optimal_width)
  }

  return(widths)
}

# Helper function to apply formatting to a worksheet
#
format_worksheet <- function(wb, sheet_name, data) {
  # Create styles for different column types
  pct_style <- createStyle(numFmt = "0.00%")
  number_style <- createStyle(numFmt = "#,##0")
  header_style <- createStyle(halign = "center", textDecoration = "italic")
  
  # Apply percentage formatting to pct columns
  pct_columns <- which(grepl("^pct", names(data), ignore.case = TRUE))
  if (length(pct_columns) > 0) {
    for (col in pct_columns) {
      addStyle(wb, sheet_name, pct_style, rows = 2:(nrow(data) + 1), cols = col)
    }
  }
  
  # Apply number formatting to other numeric columns (excluding pct columns)
  numeric_columns <- which(sapply(data, is.numeric))
  non_pct_numeric_columns <- setdiff(numeric_columns, pct_columns)
  if (length(non_pct_numeric_columns) > 0) {
    for (col in non_pct_numeric_columns) {
      addStyle(wb, sheet_name, number_style, rows = 2:(nrow(data) + 1), cols = col)
    }
  }
  
  # Apply header formatting to all column headers
  addStyle(wb, sheet_name, header_style, rows = 1, cols = 1:ncol(data))
  
  # Set smart column widths
  col_widths <- smart_col_widths(data)
  setColWidths(wb, sheet_name, cols = 1:ncol(data), widths = col_widths)
  
  return(wb)
}

# Function to save data to a formatted Excel file
#
save_formatted_excel <- function(data, filename, sheet_name = "Data", 
                                zoom_level = 125, date_stamp = TRUE) {
  
  # Add date stamp to filename if requested
  if (date_stamp) {
    date_str <- format(Sys.Date(), "%y%m%d")
    filename <- gsub("\\.xlsx$", paste0("_", date_str, ".xlsx"), filename)
  }
  
  # Create workbook and add data
  wb <- createWorkbook()
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet_name, data)
  
  # Apply formatting using helper function
  wb <- format_worksheet(wb, sheet_name, data)
  
  # Set zoom level if specified
  if (!is.null(zoom_level)) {
    wb <- set_zoom(wb, 1, zoom_level)
  }
  
  # Save the workbook
  saveWorkbook(wb, filename, overwrite = TRUE)
  cat("Data saved to:", filename, "\n")
  
  return(filename)
}

# Function to save multiple datasets to different sheets in one Excel file
#
save_multi_sheet_excel <- function(data_list, filename, sheet_names = NULL, 
                                  zoom_level = 125, date_stamp = TRUE) {
  
  # Add date stamp to filename if requested
  if (date_stamp) {
    date_str <- format(Sys.Date(), "%y%m%d")
    filename <- gsub("\\.xlsx$", paste0("_", date_str, ".xlsx"), filename)
  }
  
  # Set default sheet names if not provided
  if (is.null(sheet_names)) {
    if (!is.null(names(data_list))) {
      sheet_names <- names(data_list)
    } else {
      sheet_names <- paste0("Sheet", 1:length(data_list))
    }
  }
  
  # Create workbook
  wb <- createWorkbook()
  
  # Process each dataset
  for (i in 1:length(data_list)) {
    data <- data_list[[i]]
    sheet_name <- sheet_names[i]
    
    # Add worksheet and data
    addWorksheet(wb, sheet_name)
    writeData(wb, sheet_name, data)
    
    # Apply formatting using helper function
    wb <- format_worksheet(wb, sheet_name, data)
    
    # Set zoom level for each sheet
    if (!is.null(zoom_level)) {
      wb <- set_zoom(wb, i, zoom_level)
    }
  }
  
  # Save the workbook
  saveWorkbook(wb, filename, overwrite = TRUE)
  cat("Multi-sheet data saved to:", filename, "\n")
  
  return(filename)
}