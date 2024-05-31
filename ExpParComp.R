library(foreach)
library(doParallel)
library(tidyverse)
library(fs)

cores <- detectCores()


enter_Date <- "14-05-24"

folder_path <- paste0("data/", enter_Date)

filter_ <- dir_ls(folder_path, regexp = "Flow")

#Takes in temp, humidity & flow log as text and replaces every unprintable character with ""
file_content_1 <- readLines(dir_ls(folder_path, regexp = "Flow")) %>%
  str_replace_all("[^[:print:]]", "")

#Takes in temp reading (from PID)
file_content_2 <- readLines(dir_ls(folder_path, regexp = "Regelung")) %>%
  str_replace_all("[^[:print:]]", "")

#Takes in vaisala_in sensor log
file_content_3 <- readLines(dir_ls(folder_path, regexp = "In")) %>%
  str_replace_all("[^[:print:]]", "")

#Takes in vaisala_out sensor log
file_content_4 <- readLines(dir_ls(folder_path, regexp = "Out")) %>%
  str_replace_all("[^[:print:]]", "")


#----------------------------------------------------------------------------------
cleanData <- function(file_content_1, file_content_2, file_content_3,file_content_4)
{
  # log 1
  line_filter_1 <- grep("temp\\(C\\):\\d+\\.\\d+ humidity\\(%\\):\\d+\\.\\d+ flow\\(L/m\\):\\d+",
                        file_content_1,
                        value = TRUE)

  file_content_1_data <- line_filter_1 %>%
    str_extract_all("temp\\(C\\):\\d+\\.\\d+|humidity\\(%\\):\\d+\\.\\d+|flow\\(L/m\\):\\d+") %>%
    map(~str_extract_all(., "\\d+\\.\\d+|\\d+") %>% #~anonymous function or formulae, .=> iterates over each element of list (specifies map function which to iterate over)
          unlist() %>% #flatens the list to a vector
          as.numeric())

  sensor_1_df <- do.call(rbind, file_content_1_data) %>%
    as.data.frame() %>%
    setNames(c("temperature(C)", "humidity(%)", "flow(L\\m)"))

  temp_hum_flow <- as_tibble(sensor_1_df)

  #log 2
  line_filter_2 <- grep("^Air-T = -?\\d+\\.\\d+ C  ;  Duty_AIR = \\d+\\.\\d+ %  ;  Probe-T = \\d+\\.\\d+ C  ;  Duty_PROBE = -?\\d+\\.\\d+ %$",
                        file_content_2,
                        value = TRUE)

  file_content_2_data <- line_filter_2 %>%
    str_extract_all("^Air-T = -?\\d+\\.\\d+ C  ;  Duty_AIR = \\d+\\.\\d+ %  ;  Probe-T = \\d+\\.\\d+ C  ;  Duty_PROBE = -?\\d+\\.\\d+ %$") %>%
    map(~str_extract_all(., "\\d+\\.\\d+") %>%
          unlist() %>%
          as.numeric())

  sensor_2_df <- do.call(rbind, file_content_2_data) %>%
    as.data.frame() %>%
    setNames(c("Air-T(C)", "Duty_Air", "Probe-T(C)", "Duty_Probe"))

  AirT_ProbeT <- as_tibble(sensor_2_df) |>
    select(`Air-T(C)`, `Probe-T(C)`)

  #log 3
  line_filter_3 <- grep("(\\d+\\.\\d+)\\sppm\\s(\\d+:\\d{2}:\\d{2})",file_content_3, value = TRUE)

  #The below code only matches the first entry and outputs a matrix using this bcz it was found easier to deal with string in time format unlike the above cases which where numerical values; I am unaware of implementing 'and' operator with regex.
  matches <- str_match(line_filter_3,  "(\\d+\\.\\d+)\\sppm\\s(\\d+:\\d{2}:\\d{2})")

  sensor_3_df <- data.frame("CO2" = as.numeric(matches[, 2]), "Time" = matches[, 3])
  vaisala_in <- as_tibble(sensor_3_df) |>
    mutate(`Time` = hms(`Time`), seconds = hour(`Time`) * 3600 + minute(`Time`) * 60 + second(`Time`),
           elapsed_Time = as.numeric(difftime(seconds, first(seconds)),units = "mins"))

  #log 4
  line_filter_4 <- grep("(\\d+\\.\\d+)\\sppm\\s(\\d+:\\d{2}:\\d{2})",file_content_4, value = TRUE)
  matches <- str_match(line_filter_4,  "(\\d+\\.\\d+)\\sppm\\s(\\d+:\\d{2}:\\d{2})")

  sensor_4_df <- data.frame("CO2" = as.numeric(matches[, 2]), "Time" = matches[, 3])
  vaisala_out <- as_tibble(sensor_4_df) |>
    mutate(`Time` = hms(`Time`), seconds = hour(`Time`) * 3600 + minute(`Time`) * 60 + second(`Time`),
           elapsed_Time = as.numeric(difftime(seconds, first(seconds)),units = "mins"))

  return(list(temp_hum_flow, AirT_ProbeT, vaisala_in, vaisala_out))
}

c <- cleanData(file_content_1, file_content_2, file_content_3,file_content_4)


N=15
pb <- txtProgressBar(min = 0, max = N, style = 3)

for (i in 1:N)
{
  c <- cleanData(file_content_1, file_content_2, file_content_3,file_content_4)
  setTxtProgressBar(pb, i)
}





