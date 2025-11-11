# api/entrypoint.R
library(plumber)

port <- as.integer(Sys.getenv("PORT", "8000"))
root <- getwd()  # 컨테이너에서 WORKDIR로 설정됨

pr(file.path(root, "api", "Plumber_4.R")) |>
  pr_set_docs(FALSE) |>
  pr_set_debug(FALSE) |>
  pr_set_error(function(req, res, err){
    res$status <- 500
    res$setHeader("Content-Type", "application/json; charset=utf-8")
    list(error = conditionMessage(err))
  }) |>
  pr_run(host = "0.0.0.0", port = port)



# windows powersehll에서 함께 실행.
# 34Gc6j0gGWiR4Dd0XC1mYKhKWul_4Weew9mhn3sduzXqGptdu
# ngrok config add-authtoken $YOUR_AUTHTOKEN
# ngrok http 8000

#https://hyunwoo-j00.github.io/TBI-Prognostic-Calculator-AJOU-Models-Clinical-CT-Full---Base-Alternative-/
