FROM r-base:4.3.1

# Install system dependencies for common R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install essential R packages in one go
RUN R -e "install.packages(c( \
    'tidyverse','data.table','plumber','jsonlite','httr','curl','Rcpp', \
    'MASS','mvtnorm','survival','Matrix','nlme', \
    'actuar','triangle','fitdistrplus','zipfR', \
    'devtools','remotes','roxygen2','testthat' \
), repos='https://cloud.r-project.org')"

# Install archived dependencies (needed for stratifyR)
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/mc2d/mc2d_0.1-18.tar.gz', repos=NULL, type='source')" \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/stratifyR/stratifyR_1.0-4.tar.gz', repos=NULL, type='source')"

# Copy API code
COPY api.R /app/api.R
WORKDIR /app

# Expose port for Render
EXPOSE 8000

# Run the API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))"]
