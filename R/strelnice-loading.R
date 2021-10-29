#' Loads data from passed path
#'
#' @param filepth
#'
#' @return
#' @export
#'
#' @examples
load_strelnice_results <- function(filepth){
  participant <- parse_participant(filepth)
  timestamp <- parse_timestamp(filepth)
  log <- brainvr.reader::load_brainvr_log(filepth, quote="")
  df_log <- preprocess_results_log(log$data)
  stats <- data.frame()
  params <- data.frame()
  for(i in 1:nrow(df_log)){
    type <- df_log[i, "Event"]
    if(type == "leveStart"){
      out <- jsonlite::fromJSON(df_log[i, "Results"])
      out$timestamp <- timestamp
      out$participant <- participant
      params <- rbind(params, out)
    }
    if(type == "levelEnd"){
      out <- jsonlite::fromJSON(df_log[i, "Results"])
      out$timestamp <- timestamp
      out$participant <- participant
      stats <- rbind(stats, out)
    }
  }
  stats <- remove_percentages(stats)
  stats <- calculate_averages(stats)
  return(list(stats = stats, params = params))
}
