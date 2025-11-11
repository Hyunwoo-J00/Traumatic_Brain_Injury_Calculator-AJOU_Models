# ---- External validation (minimal) ----
# 필요 패키지: pROC, caret, jsonlite
library(pROC); library(caret); library(jsonlite)
source(file.path("C:/Users/niced/Desktop/TBI_risk_factor_R/소스코드/Full_A_Death_Split_Lasso_1se_repro","predict_template.R"))

# df_ext : 외부 원자료(사용자 준비)
# 응답변수명: "14d_death" (0/1 factor or character -> factor(c("0","1")))
# X_ext  : (선택) 사용자가 만든 model.matrix 결과 (Intercept 제외)

external_validate <- function(df_ext, response_col, X_ext = NULL, threshold = 0.5){
  if (is.null(X_ext)) {
    form <- try(as.formula(specs$formula), silent = TRUE)
    if (inherits(form, "try-error")) stop("specs$formula 없음")
    mf   <- model.frame(form, data = df_ext, na.action = na.omit)
    yfac <- mf[[response_col]]
    if (!is.factor(yfac)) yfac <- factor(as.character(yfac), levels = c("0","1"))
    X_ext <- model.matrix(form, data = mf)[,-1,drop=FALSE]
  } else {
    mf <- df_ext
    yfac <- mf[[response_col]]
    if (!is.factor(yfac)) yfac <- factor(as.character(yfac), levels = c("0","1"))
  }
  p <- predict_prob(X_ext, standardize = FALSE)
  truth <- factor(as.character(yfac), levels=c("0","1"))
  pred  <- factor(ifelse(p >= threshold, "1", "0"), levels=c("0","1"))
  cm    <- caret::confusionMatrix(pred, truth, positive = "1")
  roc_o <- pROC::roc(truth, p, levels=c("0","1"), direction="<")
  y01   <- as.integer(as.character(truth))
  list(
    AUROC = as.numeric(pROC::auc(roc_o)),
    Accuracy  = unname(cm$overall["Accuracy"]),
    Recall    = unname(cm$byClass["Sensitivity"]),
    Precision = unname(cm$byClass["Pos Pred Value"]),
    Brier = mean((p - y01)^2),
    N = length(p),
    Events = sum(truth=="1")
  )
}
