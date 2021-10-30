#' Loads data from passed path
#'
#' @param filepth
#'
#' @return
#' @export
#'
#' @examples
load_strelnice_results <- function(filepth){
  log <- brainvr.reader::load_brainvr_log(filepth, quote="")
  df_log <- preprocess_results_log(log$data)
  stats <- data.frame()
  params <- data.frame()
  for(i in seq_len(nrow(df_log))){
    type <- df_log[i, "Event"]
    out <- jsonlite::fromJSON(df_log[i, "Results"])
    out$timestamp <- log$session_header$Timestamp
    out$participant <- log$session_header$Participant
    out <- sapply(out, convert_vector_to_string,
                  USE.NAMES = TRUE, simplify = FALSE)
    if(type == "levelStart"){
      params <- rbind(params, out)
    }
    if(type == "levelEnd"){
      stats <- rbind(stats, out)
    }
  }
  stats <- remove_percentages(stats)
  stats <- calculate_averages(stats)
  return(list(stats = stats, params = params))
}

convert_vector_to_string <- function(val){
    val <- ifelse(length(val) > 1,
                  paste0("[", paste0(val, collapse = ", "), "]"),
                  val)
    return(val)
}
