
# ---- AJOU model reproducibility template (R) ----
# 필요 패키지: jsonlite
library(jsonlite)

# 파일 경로
repro_dir <- "C:/Users/niced/Desktop/TBI_risk_factor_R/소스코드/Clinical_A_6Month_Lasso_0.025_Split_repro"
coef_df   <- read.csv(file.path(repro_dir, "coefficients.csv"), check.names = FALSE)
scaling   <- read.csv(file.path(repro_dir, "scaling_stats.csv"), check.names = FALSE)
col_order <- readLines(file.path(repro_dir, "column_order.txt"))
fac_spec  <- jsonlite::fromJSON(file.path(repro_dir, "factor_spec.json"))
spl_spec  <- jsonlite::fromJSON(file.path(repro_dir, "spline_spec.json"))
specs     <- jsonlite::fromJSON(file.path(repro_dir, "specs.json"))

# 2) 전처리 결과: X_new (model.matrix 결과; Intercept 제외)
align_X <- function(X){
  miss <- setdiff(col_order, colnames(X))
  if (length(miss)) {
    add <- matrix(0, nrow=nrow(X), ncol=length(miss)); colnames(add) <- miss
    X <- cbind(X, add)
  }
  extra <- setdiff(colnames(X), col_order)
  if (length(extra)) X <- X[, setdiff(colnames(X), extra), drop=FALSE]
  X[, col_order, drop=FALSE]
}

# (참고) glmnet 계수는 원 스케일 복원되어 제공됨. 외부 예측시 재표준화 불필요.
standardize_X <- function(X, scaling){
  mu <- setNames(scaling$mean, scaling$feature)
  sd <- setNames(scaling$sd,   scaling$feature)
  for (nm in intersect(colnames(X), names(mu))) X[, nm] <- (X[, nm] - mu[[nm]]) / sd[[nm]]
  X
}

predict_prob <- function(X_new, standardize = FALSE){
  btab <- setNames(coef_df$coef, coef_df$feature)
  b0   <- unname(btab["(Intercept)"])
  beta <- btab[setdiff(names(btab), "(Intercept)")]
  X_aligned <- align_X(X_new)
  if (isTRUE(standardize)) X_aligned <- standardize_X(X_aligned, scaling)
  eta <- as.numeric(b0 + X_aligned %*% as.numeric(beta[colnames(X_aligned)]))
  1/(1+exp(-eta))
}

