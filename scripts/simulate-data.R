n_group <- 3
n_data <- 50

mu_alpha <- 0
sigma_alpha <- 0.25

mu_phi <- 2
sigma_phi <- 0.1

sigma_noise <- 0.25

alpha_vec <- rnorm(n = n_group, mean = mu_alpha, sd = sigma_alpha)
phi <- rnorm(n = 1, mean = mu_phi, sd = sigma_phi)

x_mat <- matrix(
  runif(n_group * n_data),
  nrow = n_data,
  ncol = n_group
)

y_mat <- matrix(nrow = n_data, ncol = n_group)

for (ii in 1 : n_group) {
  y_mat[, ii] <- alpha_vec[ii] + x_mat[, ii] * phi + rnorm(n = n_data, sd = sigma_noise)
}

sim_pars <- list(
  n_data = n_data, 
  n_group = n_group,
  mu_alpha = mu_alpha,
  sigma_alpha = sigma_alpha,
  mu_phi = mu_phi,
  sigma_phi = sigma_phi,
  sigma_noise = sigma_noise
)

saveRDS(
  object = sim_pars,
  file = "rds/sim-pars.rds"
)

sim_data <- list(
  y_mat = y_mat,
  x_mat = x_mat
)

saveRDS(
  object = sim_data,
  file = "rds/sim-data.rds"
)
