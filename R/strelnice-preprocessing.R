#' Title
#'
#' @param df
#'
#' @return
#' @export
#' @import dplyr
#'
#' @examples
preprocess_results_log <- function(df){
  df <- mutate(df, across(where(is.character), stringr::str_trim))
  return(df)
}

remove_percentages <- function(df){
  cols <- c("successRatePercentage")
  for(col in cols){
    df[[col]] <- sapply(df[[col]],
                        function(x){as.numeric(gsub("%", "", x))},
                        USE.NAMES = FALSE)
  }
  return(df)
}

calculate_averages <- function(df){
  cols <- c("enemyReactionTimes", "stopSignalTime", "FriendReactionTime")
  for(col in cols){
    values <- sapply(df[[col]], separate_values, USE.NAMES = FALSE)
    df[[paste0(col, "_avg")]] <- sapply(values, mean)
  }
  return(df)
}

#' @import stringr
separate_values <- function(string){
  string <- remove_brackets(string)
  split <- str_trim(str_split(string, ",", simplify = TRUE))
  split <- split[split != "-"]
  nums <- as.numeric(split)
  return(nums)
}

remove_brackets <- function(string){
  string <- gsub("\\[|\\]", "", string)
  return(string)
}
