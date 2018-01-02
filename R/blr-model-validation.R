#' @title Confusion Matrix
#' @description Confusion matrix
#' @param model an object of class \code{glm}
#' @param data a tibble
#' @param cutoff cutoff for classification
#' @return table
#' @examples
#' model <- glm(honcomp ~ female + read + science, data = hsb2,
#'             family = binomial(link = 'logit'))
#'
#' blr_confusion_matrix(model, hsb2, 0.4)
#' @export
#'
blr_confusion_matrix <- function(model, data, cutoff) UseMethod('blr_confusion_matrix')

#' @export
#'
blr_confusion_matrix.default <- function(model, data, cutoff) {

  resp <- model %>%
    formula %>%
    extract2(2) %>%
    as.character

  conf_matrix <- data %>%
    mutate(
      prob = predict.glm(object = model, type = 'response'),
      predicted = if_else(prob > cutoff, 1, 0)
    ) %>%
    select(resp, predicted) %>%
    table

  accuracy <- conf_matrix %>%
    diag %>%
    sum %>%
    divide_by(conf_matrix %>%
                sum)

  precision <- conf_matrix %>%
    diag %>%
    `[`(2) %>%
    unname %>%
    divide_by(conf_matrix %>%
                `[`(, 2) %>%
                sum)

  sensitivity <- conf_matrix %>%
    diag %>%
    `[`(2) %>%
    unname %>%
    divide_by(conf_matrix %>%
                `[`(2, ) %>%
                sum)

  specificity <- conf_matrix %>%
    diag %>%
    `[`(1) %>%
    unname %>%
    divide_by(conf_matrix %>%
                `[`(1, ) %>%
                sum)

  result <- list(
    confusion_matrix = conf_matrix,
    accuracy = accuracy,
    precision = precision,
    sensitivity = sensitivity,
    specificity = specificity
  )
  class(result) <- 'blr_confusion_matrix'
  return(result)
}