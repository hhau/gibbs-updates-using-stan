data {
  int <lower = 0> n_group;
  int <lower = 0> n_data;

  matrix [n_data, n_group] y_mat;
  matrix [n_data, n_group] x_mat;

  // gibbs bits
  real phi;

  // prior parts
  real <lower = 0> sigma_alpha;
  real <lower = 0> sigma_phi;
  real <lower = 0> sigma_noise;
  real mu_alpha;
  real mu_phi;
}

parameters {
  vector [n_group] alpha;
}

model {
  for (jj in 1 : n_group) {
    target += normal_lpdf(y_mat[, jj] | alpha[jj] + x_mat[, jj] * phi, sigma_noise);
  }

  // priors
  target += normal_lpdf(alpha | mu_alpha, sigma_alpha);
  target += normal_lpdf(phi | mu_phi, sigma_phi);
}
