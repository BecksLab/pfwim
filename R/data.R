#' Example species traits data to infer feeding rules
#'
#' A mock trait dataset using four trait classes to determine interactions
#' as specified in `feeding_rules`
#'
#' @format ## `traits`
#' A data frame with 7,240 rows and 60 columns:
#' \describe{
#'   \item{species}{species name}
#'   \item{motility}{motility class of species}
#'   \item{habitat}{habitat species found in}
#'   \item{feeding}{trophic level of species}
#'   \item{size}{categorical size classes}
#'   ...
#' }
#' @source NA
"traits"

#' Example feeding rules for `traits`
#'
#' A mock trait dataset using four trait classes specified in `traits`
#' to infer feeding interactions
#'
#' @format ## `feeding_rules`
#' A data frame with 7,240 rows and 60 columns:
#' \describe{
#'   \item{trait_type_resource}{broader resource trait class - i.e. column name in traits}
#'   \item{trait_resource}{specific resource trait class - i.e. row entry in trait column}
#'   \item{trait_type_consumer}{broader consumer trait class - i.e. column name in traits}
#'   \item{trait_consumer}{specific consumer trait class - i.e. row entry in trait column}
#'   ...
#' }
#' @source NA
"feeding_rules"

#' Example feeding rules for `traits`
#'
#' A mock trait dataset using four trait classes specified in `traits`
#' to infer feeding interactions
#'
#' @format ## `feeding_rules`
#' A data frame with 7,240 rows and 60 columns:
#' \describe{
#'   \item{trait_type_resource}{broader resource trait class - i.e. column name in traits}
#'   \item{trait_resource}{specific resource trait class - i.e. row entry in trait column}
#'   \item{trait_type_consumer}{broader consumer trait class - i.e. column name in traits}
#'   \item{trait_consumer}{specific consumer trait class - i.e. row entry in trait column}
#'   ...
#' }
#' @source NA
"feeding_rules"
