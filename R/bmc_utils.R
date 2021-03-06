#' Search for gene sequences available for a species from NCBI.
#'
#' @export
#' @keywords internal
#' @param query Search terms.
#' @param limit Number of records to return. Default 10.
#' @param offset Record number to start at. Default: 1
#' @param ... Further args passed on to [httr::GET()]
#' @return A list of length 2
#' @examples \dontrun{
#' bmc_search(query='ecology')
#' bmc_search('fire', limit=3)
#' bmc_search('fire', limit=2, page=1)
#' bmc_search('fire', limit=2, page=2)
#'
#' # Search, then get full text
#' out <- bmc_search('ecology')
#' (urls <- vapply(out$records$url, "[[", "", 'value'))
#' browseURL(urls[1])
#'
#' # curl debugging help
#' library('httr')
#' bmc_search('ecology', config=verbose())
#' }
bmc_search <- function(query, limit = 10, offset = 1, key = NULL, ...) {
  url <- 'http://api.springer.com/metadata/json'
  args <- ft_compact(list(q = query, p = limit, s = offset, api_key = check_key_bmc(key)))
  out <- GET(url, query = args, ...)
  stop_for_status(out)
  tt <- content(out, "text", encoding = 'UTF-8')
  res <- jsonlite::fromJSON(tt)
  res$result$total <- as.numeric(res$result$total)
  return(res)
}

check_key_bmc <- function(x) {
  tmp <- if (is.null(x))
    Sys.getenv("SPRINGER_KEY", "")
  else x
  if (tmp == "") {
    getOption("springer_key", stop("you need an API key for the Springer/BMC API",
                                        call. = FALSE))
  }
  else {
    tmp
  }
}
