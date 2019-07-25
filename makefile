RSCRIPT = Rscript

# if you wildcard the all-target, then nothing will happen if the target doesn't
# exist (no target). hard code the target.
WRITEUP = gibbs-updates-using-stan.pdf

TEX_FILES = $(wildcard tex-input/*.tex) \
	$(wildcard tex-input/*/*.tex) \
	$(wildcard tex-input/*/*/*.tex)

SIM_PARS = rds/sim-pars.rds
SIM_DATA = rds/sim-data.rds

PLOT_SETTINGS = scripts/common/plot-settings.R
PLOTS = plots/phi-qq-plot.pdf \
	plots/alpha-trace.pdf

all : $(WRITEUP)

# knitr is becoming more picky about encoding, specify UTF-8 input
$(WRITEUP) : $(wildcard *.rmd) $(TEX_FILES) $(PLOTS)
	$(RSCRIPT) -e "rmarkdown::render(input = Sys.glob('*.rmd'), encoding = 'UTF-8')"

# setup and data
rds/sim-pars.rds : scripts/simulate-data.R
	$(RSCRIPT) $<

rds/sim-data.rds : rds/sim-pars.rds

# joint baseline comparision
rds/joint-samples.rds : scripts/joint-baseline/sample-joint.R $(SIM_DATA) $(SIM_PARS) scripts/stan-files/overall-model.stan
	$(RSCRIPT) $<

# Gibbs samples
rds/gibbs-samples.rds : scripts/gibbs-updates/sample-using-gibbs.R $(SIM_DATA) $(SIM_PARS) $(wildcard scripts/stan-files/*-update.stan)
	$(RSCRIPT) $<

plots/phi-qq-plot.pdf : scripts/compare-joint-gibbs.R $(PLOT_SETTINGS) rds/joint-samples.rds rds/gibbs-samples.rds
	$(RSCRIPT) $<

plots/alpha-trace.pdf : plots/phi-qq-plot.pdf