args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--PATH') {
    
    PATH <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

if (length(unused_args) > 0) {
  print(paste('WARNING: unused arguments ', unused_args))
}

# PATH <- 'C:/Users/john/Documents/sample_fmri/2357ZL'
# COND <- 'Retrieval'

#### Main Body ####

library(ggplot2)

output_path <- file.path(PATH, 'mot_analysis')
fig_path    <- file.path(output_path, 'plots')
dir.create(fig_path, recursive = T, showWarnings = F)

DVARS <- read.csv( file.path(output_path, 'DVARS.csv'), header = T, row.names = 1 )

DVARS.mean <- mean(DVARS$DVARS)
DVARS.mae  <- mean( abs( DVARS$DVARS - DVARS.mean ) )

plot_DVARS <- 
  ggplot(mapping = aes(x = 1:dim(DVARS)[1], y = DVARS$DVARS) ) +
  geom_line(colour = 'firebrick1', size = 0.75, alpha = 0.8 ) + 
  scale_x_continuous(limits = c( 0, dim(DVARS)[1] ), expand = c(0, 0)) +
  geom_hline(aes(yintercept = DVARS.mae + DVARS.mean), colour = 'grey40', linetype = 4, size = 0.75, alpha = 0.7) +
  ggtitle('Framewise Displacement (FD) Across Time') +
  xlab('time (TRs)') +
  ylab(paste0('DVARS ( delta BOLD )')) + 
  theme_minimal() +
  theme(axis.line.x = element_line(size = 0.5, colour = "black"),
        axis.line.y = element_line(size = 0.5, colour = "black"),
        panel.grid.major = element_line(size = 0, colour = 'white'),
        panel.grid.minor = element_line(size = 0, colour = 'white'), 
        plot.title = element_text(hjust = 0.5) )

ggsave(plot = plot_DVARS, filename = file.path(fig_path, paste0(COND, '_DVARS.pdf') ), units = 'cm', width = 16, height = 9)