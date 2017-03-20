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

require(ggplot2,   quietly = T)
require(grid,      quietly = T)
require(gridExtra, quietly = T)

head_rad   <- 50 # distance from center for brain to cortex, in mm
sys_cmd    <- paste0('3dinfo -adi -adj -adk ', file.path(PATH, 'fun'),  '/', COND, '.nii*' )

voxel_size <- system(sys_cmd, intern = T)
voxel_size <- strsplit(voxel_size, split = '\t')[[1]]
voxel_size <- as.numeric(voxel_size)
voxel_size <- min(voxel_size)

output_path <- file.path(PATH, 'MPEs')
fig_path    <- file.path(output_path, 'plots')
dir.create(fig_path, recursive = T, showWarnings = F)

mpe_mm           <- read.table( file.path( PATH, 'MPEs', paste0('mm_', COND, '.1D') ) )
colnames(mpe_mm) <- c('roll', 'pitch', 'yaw', 'mmS', 'mmL', 'mmP')

mpe           <- read.table( file.path( PATH, 'MPEs', paste0(COND, '.1D') ) )
colnames(mpe) <- c('roll', 'pitch', 'yaw', 'dS', 'dL', 'dP')

max_disp       <- c(voxel_size * 360 / (2 * pi * head_rad), voxel_size)
max_disp       <- max(max_disp)
if( max( abs(mpe[, c('roll', 'pitch', 'yaw') ]) ) > max_disp ) {
  max_disp <- max( abs(mpe[, c('roll', 'pitch', 'yaw') ]) )
}
max_disp.scale <- 1

breaks.major <- seq(ceiling(- max_disp.scale * max_disp), floor(max_disp.scale * max_disp), 1)
breaks.minor <- seq(floor(- max_disp.scale * max_disp) + 0.5, floor(max_disp.scale * max_disp) + 0.5, 0.5)
breaks.minor <- breaks.minor[-which(breaks.minor %% 1 == 0)]

breaks.major <- sort(c(breaks.minor, breaks.major))

plot.mpe.dist <-
  ggplot(data = mpe) +
  geom_hline(aes(yintercept = 0), colour = 'grey40', linetype = 1, size = 0.4, alpha = 0.5) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = roll , colour = 'roll' ), size = 0.6, alpha = 0.9) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = pitch, colour = 'pitch'), size = 0.6, alpha = 0.9) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = yaw  , colour = 'yaw'  ), size = 0.6, alpha = 0.9) +
  scale_colour_manual(name = 'disp. axes', values = c(
    'roll'  = 'firebrick2', 
    'pitch' = 'forestgreen',
    'yaw'   = 'dodgerblue2') ) +
  scale_x_continuous(limits        = c( 0, dim(mpe)[1] ), expand = c(0, 0)) +
  scale_y_continuous( limits       = c( - max_disp.scale * voxel_size , max_disp.scale * voxel_size ), 
                      expand       = c(0,0), 
                      breaks       = breaks.major,
                      minor_breaks = breaks.minor) +
  ggtitle('Movement: Translation & Rotation') +
  xlab('time (TRs)') +
  ylab('Displacement (mm)') + 
  theme_minimal() +
  theme(axis.line.x      = element_line(size = 0.5, colour = 'black'),
        axis.line.y      = element_line(size = 0.5, colour = 'black'),
        panel.grid.major = element_line(size = 0, colour = 'white'),
        panel.grid.minor = element_line(size = 0, colour = 'white'), 
        plot.title       = element_text(hjust = 0.5),
        axis.title.x     = element_blank(),
        axis.text.x      = element_blank(),
        axis.ticks.x     = element_blank() )

plot.mpe.rot <-
  ggplot(data = mpe) +
  geom_hline(aes(yintercept = 0), colour = 'grey40', linetype = 1, size = 0.4, alpha = 0.5) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = dS, colour = 'dS'), size = 0.8, alpha = 0.75, show.legend = T) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = dL, colour = 'dL'), size = 0.8, alpha = 0.75, show.legend = T) +
  geom_line(mapping = aes(x = 1:dim(mpe)[1], y = dP, colour = 'dP'), size = 0.8, alpha = 0.75, show.legend = T) +
  scale_colour_manual(name = 'rot. axes', values = c(
    'dS' = 'darkorchid4',
    'dL' = 'yellow3',
    'dP' = 'chocolate4') ) +
  scale_x_continuous(limits        = c( 0, dim(mpe)[1] ), expand = c(0, 0)) +
  scale_y_continuous(limits       = c( - max_disp.scale * max_disp , max_disp.scale * max_disp ),
                     expand       = c(0,0),
                     breaks       = breaks.major,
                     minor_breaks = breaks.minor) +
  xlab('time (TRs)') +
  ylab('Rotation (CCW deg)') +
  theme_minimal() +
  theme(axis.line.x      = element_line(size = 0.5, colour = 'black'),
        axis.line.y      = element_line(size = 0.5, colour = 'black'),
        panel.grid.major = element_line(size = 0, colour = 'white'),
        panel.grid.minor = element_line(size = 0, colour = 'white'))

mmpe_plot <- grid.arrange(plot.mpe.dist, plot.mpe.rot, ncol = 1)

# print(plot.mpe.dist)
# print(plot.mpe.rot)
# print(mmpe_plot)

ggsave(plot = mmpe_plot, filename = file.path(fig_path, paste0(COND, '_MPEs.pdf') ), units = 'cm', width = 16, height = 17)
