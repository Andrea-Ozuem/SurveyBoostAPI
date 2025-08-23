library(plumber)
library(stratifyR)
library(jsonlite)

# Your backend function
calc_var_stratified_mean <- function(dp_res) {
  Nh <- dp_res$Nh        # stratum population sizes
  nh <- dp_res$nh        # stratum sample sizes
  Sh2 <- dp_res$Vh       # stratum variances
  N  <- dp_res$NhTot       # total population size
  
  var_mean <- sum((Nh / N)^2 * (Sh2 / nh) * (1 - nh / Nh))
  return(var_mean)
}

run_stratification <- function(y, h, n, cost_vec = NULL, budget = NULL, fixed_cost = 0) {
  if (!is.numeric(y)) stop("Dataset must be numeric")
  if (length(y) < h) stop("Dataset must be larger than number of strata")
  
  if (!is.null(cost_vec)) {
    res <- strata.data(
      data = y,
      h    = h,
      n    = n,
      cost = TRUE,
      ch   = cost_vec
    )
  } else {
    res <- strata.data(
      data = y,
      h    = h,
      n    = n
    )
  }
  
  total_variance <- calc_var_stratified_mean(res) # total variance
  
  nh <- res$nh
  total_cost <- NULL
  feasible   <- NULL
  if (!is.null(cost_vec)) {
    variable_cost <- sum(nh * cost_vec)
    total_cost <- fixed_cost + variable_cost
    if (!is.null(budget)) {
      feasible <- (total_cost <= budget)
    }
  }
  
  output <- list(
    strata_boundaries = res$OSB,
    strata_allocation = res$nh,
    strata_sizes      = res$Nh,
    variance          = total_variance,
    total_cost        = total_cost,
    budget            = budget,
    feasible          = feasible
  )
  return(output)
}

# -------------------------------
# Plumber API endpoint
# -------------------------------

#* @get /
#* Health check endpoint
function() {
  list(status = "ok", message = "Plumber API running 🚀")
}

#* @post /stratify
#* @param data:list Numeric dataset
#* @param h:int Number of strata
#* @param n:int Sample size
#* @param cost_vec:list Optional per-unit costs per stratum
#* @param budget:int Optional budget
#* @param fixed_cost:int Fixed overhead cost
#* @serializer json
function(data, h, n, cost_vec = NULL, budget = NULL, fixed_cost = 0) {
  y <- unlist(data)
  cost_vec <- if (!is.null(cost_vec)) unlist(cost_vec) else NULL
  
  result <- run_stratification(y, as.integer(h), as.integer(n), cost_vec, as.integer(budget), as.integer(fixed_cost))
  
  return(result)
}

# -------------------------------
# Start the API (for Render)
# -------------------------------
if (sys.nframe() == 0) {
  pr <- plumber::plumb("api.R")
  pr$run(
    host = "0.0.0.0",
    port = as.numeric(Sys.getenv("PORT", 8000))
  )
}
