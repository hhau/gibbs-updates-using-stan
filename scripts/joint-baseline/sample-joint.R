library(rstan)

sim_pars <- readRDS("rds/sim-pars.rds")
sim_data <- readRDS("rds/sim-data.rds")

prefit <- stan_model(file = "scripts/stan-files/overall-model.stan")

stan_data <- wsre:::.extend_list(
  sim_pars,
  sim_data
)

model_fit <- sampling(
  prefit,
  data = stan_data
)

model_samples <- extract(model_fit, pars = c("alpha", "phi"))

saveRDS(
  object = model_samples,
  file = "rds/joint-samples.rds"
)

