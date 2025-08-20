# Use R base image
FROM r-base:4.3.1

# Install necessary R packages
RUN R -e "install.packages(c('plumber','stratifyR','jsonlite'), repos='https://cloud.r-project.org')"

# Copy API script
COPY api.R /app/api.R
WORKDIR /app

# Start Plumber API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]
