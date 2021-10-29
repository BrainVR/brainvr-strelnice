#' Loads data from passed path
#'
#' @param pth
#'
#' @return
#' @export
#'
#' @examples
load_strelnice_results <- function(filepth){
  lines <- readLines(pth)
  participant <- parse_participant(filepth)
  timestamp <- parse_timestamp(filepth)
  i_bottom <- which(grepl("Time; Results", lines))
  if(length(i_bottom) == 0 || i_bottom == length(lines)){
    return(NULL)
  }
  lines <- lines[(i_bottom + 1):length(lines)]
  stats <- data.frame()
  params <- data.frame()
  for(i in 1:length(lines)){
    line <- lines[i]
    type <- level_start_end(line)
    if(type == "start"){
      out <- parse_strelnice_params(line)
      out$timestamp <- timestamp
      out$participant <- participant
      params <- rbind(params, out)
    }
    if(type == "end"){
      out <- parse_strelnice_stats(line)
      out$timestamp <- timestamp
      out$participant <- participant
      stats <- rbind(stats, out)
    }
  }
  return(list(stats = stats, params = params))
}

parse_strelnice_params <- function(line){
  level <- level_settings_name(line)
  params <- gsub(".*params= (.*);", "\\1", line)
  params <- gsub(";", "", params)
  params <- jsonlite::fromJSON(params)
  params <- as.data.frame(params)
  params$level <- level
  return(params)
}

parse_strelnice_stats <- function(line){
  level <- level_settings_name(line)
  stats <- gsub(".* stats = (.*);", "\\1", line)
  stats <- gsub("(, )([a-zA-Z])", '\\1"\\2', stats)
  stats <- gsub("-","null", stats)
  stats <- gsub("\\%", "", stats)
  stats <- gsub("([0-9]) s,", "\\1,", stats)
  stats <- gsub(" , ", " null, ", stats)
  stats <- gsub(":", "\":", stats)
  stats <- sub("\\[", "{", stats)
  stats <- gsub("\\] $", "}", stats)
  stats <- gsub("shownTargets", '"shownTargets', stats)
  stats <- jsonlite::fromJSON(stats, simplifyVector = FALSE)
  stats$level <- level

  # TEMPORARY SOLUTION
  stats$EnemyReactionTimes <- NULL
  stats$FriendReactionTime <- NULL
  stats$StopSignalTime <- NULL

  stats <- sapply(stats, function(x){return(ifelse(is.null(x), NA, x))},
                  USE.NAMES = TRUE, simplify = FALSE)
  stats <- as.data.frame(stats)
  return(stats)
}

level_settings_name <- function(line){
  name <- gsub(".*level (.*) (.*).json.*", "\\2", line)
  return(name)
}

level_start_end <- function(line){
  return(gsub(".*level (.*) .*json.*", "\\1", line))
}

parse_participant <- function(pth){
  return(gsub("^(.*?)_.*", "\\1", basename(pth)))
}

parse_timestamp <- function(pth){
  return(gsub(".*_(.*)\\.txt", "\\1", basename(pth)))
}
