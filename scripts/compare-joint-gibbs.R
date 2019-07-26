library(tibble)

source("scripts/common/plot-settings.R")

joint_samples <- readRDS("rds/joint-samples.rds")
gibbs_samples <- readRDS("rds/gibbs-samples.rds")

# qq plot of the phis
plot_quantiles <- seq(from = 0.001, to = 0.999, length.out = 250)

plot_tbl <- tibble(
  x = quantile(joint_samples$phi, plot_quantiles),
  y = quantile(gibbs_samples$phi, plot_quantiles)
)

p1 <- ggplot(plot_tbl, aes(x = x, y = y)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  xlab("Joint") +
  ylab("Gibbs")

ggsave_halfheight(
  filename = "plots/phi-qq-plot.pdf",
  plot = p1
)

## traces of the alphas

n_samples_to_trace <- 1000

alpha_tbl_joint <- tibble(
  x = rep(1 : n_samples_to_trace, times = ncol(joint_samples$alpha)),
  y = as.vector(joint_samples$alpha[1 : n_samples_to_trace, ]),
  par = rep(1 : 3, each = n_samples_to_trace),
  target = "Joint"
)

alpha_tbl_gibbs <- tibble(
  x = rep(1 : n_samples_to_trace, times = ncol(gibbs_samples$alpha)),
  y = as.vector(gibbs_samples$alpha[1 : n_samples_to_trace, ]),
  par = rep(1 : 3, each = n_samples_to_trace),
  target = "Gibbs"
)

plot_tbl <- dplyr::bind_rows(alpha_tbl_joint, alpha_tbl_gibbs)

p2 <- ggplot(plot_tbl, aes(x = x, y = y, col = target)) +
  geom_line(alpha = 0.9) +
  facet_wrap(vars(par), scales = "free_y") +
  scale_colour_manual(
    values = c(
      Joint = greens[4],
      Gibbs = as.character(blues[2])
    )
  ) +
  labs(col = "Update type")

ggsave_halfheight(
  filename = "plots/alpha-trace.pdf",
  plot = p2
)
