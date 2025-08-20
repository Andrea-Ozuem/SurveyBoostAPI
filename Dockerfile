# Base R image
FROM r-base:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required R packages
RUN R -e "install.packages(c('plumber','jsonlite'), repos='https://cloud.r-project.org')"

# Install stratifyR (CRAN)
RUN R -e "install.packages('stratifyR', repos='https://cloud.r-project.org')"

# Copy API
COPY api.R /app/api.R
WORKDIR /app

# Run the API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]
