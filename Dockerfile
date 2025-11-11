# Dockerfile (빠르고 안정적)
FROM rocker/r2u:jammy

WORKDIR /app
# CRAN 패키지의 바이너리 설치 (매우 빠름)
RUN apt-get update && apt-get install -y \
    r-cran-plumber r-cran-jsonlite && \
    rm -rf /var/lib/apt/lists/*

# 소스/모델 복사
COPY api/ /app/api/
COPY models/ /app/models/

EXPOSE 8000
CMD ["Rscript", "/app/api/Entrypoint.R"]

