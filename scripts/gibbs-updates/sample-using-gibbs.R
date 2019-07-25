library(rstan)
library(futile.logger)

sim_pars <- readRDS("rds/sim-pars.rds")
sim_data <- readRDS("rds/sim-data.rds")

phi_prefit <- stan_model("scripts/stan-files/phi-update.stan")
alpha_prefit <- stan_model("scripts/stan-files/alpha-update.stan")

alpha_init <- c(0, -0.1, 0.1)
phi_init <- 2

base_stan_data <- wsre:::.extend_list(
  sim_pars,
  sim_data
)

n_mcmc <- 1000

alpha_gibbs_samples <- matrix(NA, nrow = n_mcmc + 1, ncol = sim_pars$n_group)
phi_gibbs_samples <- rep(NA, times = n_mcmc + 1)

alpha_gibbs_samples[1, ] <- alpha_init 
phi_gibbs_samples[1] <- phi_init

for (ii in 2 : (n_mcmc + 1)) {
  # phi step
  phi_stan_data <- wsre:::.extend_list(
    base_stan_data,
    list(alpha = alpha_gibbs_samples[ii - 1,])
  )
  
  phi_step <- rstan::sampling(
    phi_prefit,
    data = phi_stan_data,
    init = list(list(phi = phi_gibbs_samples[ii - 1])),
    iter = 501,
    warmup = 500,
    chains = 1,
    refresh = 0 
  )
  phi_sample <- as.vector(as.array(phi_step, pars = "phi"))
  phi_gibbs_samples[ii] <- phi_sample
    
  # alpha step
  alpha_stan_data <- wsre:::.extend_list(
    base_stan_data,
    list(phi = phi_gibbs_samples[ii])
  )
  
  alpha_step <- rstan::sampling(
    alpha_prefit,
    data = alpha_stan_data,
    init = list(list(alpha = alpha_gibbs_samples[ii - 1, ])),
    iter = 501,
    warmup = 500,
    chains = 1,
    refresh = 0
  )
  alpha_sample <- as.vector(as.array(alpha_step, pars = "alpha"))
  alpha_gibbs_samples[ii, ] <- alpha_sample
  
  if (ii %% 100 == 0) {
    flog.info(sprintf("Iter: %d", ii))  
  }  
  
}

output_list <- list(
  alpha = alpha_gibbs_samples,
  phi = phi_gibbs_samples
)

saveRDS(
  object = output_list,
  file = "rds/gibbs-samples.rds"
)
