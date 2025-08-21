FROM r-base:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Install core R packages
RUN R -e "install.packages(c('plumber','jsonlite'), repos='https://cloud.r-project.org')"

# Install stratifyR dependencies (some from CRAN Archive)
RUN R -e "install.packages(c('fitdistrplus', 'zipfR', 'actuar', 'triangle'), repos='https://cloud.r-project.org')" \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/mc2d/mc2d_0.1-18.tar.gz', repos=NULL, type='source')" \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/stratifyR/stratifyR_1.0-4.tar.gz', repos=NULL, type='source')"

# Copy API code
COPY api.R /app/api.R
WORKDIR /app

# Expose port for Render
EXPOSE 8000

# Run the API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]
