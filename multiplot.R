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

require(ggplot2  , quietly = T)
require(grid     , quietly = T)
require(gridExtra, quietly = T)

output_path <- file.path(PATH, 'mot_analysis')
fig_path    <- file.path(output_path, 'plots')
dir.create(fig_path, recursive = T, showWarnings = F)

#### Main Body ####

head_rad   <- 50 # distance from center for brain to cortex, in mm
sys_cmd    <- paste0('3dinfo -adi -adj -adk ', file.path(PATH, 'fun', 'preproc'),  '/snlmt_', COND, '.nii.gz' )

voxel_size <- system(sys_cmd, intern = T)
voxel_size <- strsplit(voxel_size, split = '\t')[[1]]
voxel_size <- as.numeric(voxel_size)
voxel_size <- min(voxel_size)

FD    <- read.csv( file.path(PATH, 'mot_analysis', paste0(COND, '_FD.csv'   ) ), header = T, row.names = 1)
DVARS <- read.csv( file.path(PATH, 'mot_analysis', paste0(COND, '_DVARS.csv') ), header = T, row.names = 1)

MOVE_TAB <- data.frame(FD = FD[,1], DVARS = c(NA, DVARS[,1]) )

max_disp.scale <- 1

max_disp.FD       <- c(voxel_size * 360 / (2 * pi * head_rad), voxel_size)
max_disp.FD       <- max(max_disp.FD)
if( max( abs(MOVE_TAB$FD) ) > voxel_size ) {
  max_disp.FD <- max( abs(MOVE_TAB$FD) ) 
}

max_disp.DVARS <- 100
if( max( abs(MOVE_TAB$DVARS) ) > max_disp.DVARS ) {
  max_disp.DVARS <- max( abs(MOVE_TAB$DVARS) )
}

plot_FD <- 
  ggplot(mapping = aes(x = 1:dim(MOVE_TAB)[1], y = MOVE_TAB$FD)) + 
  geom_hline(aes(yintercept = 0), colour = 'grey40', linetype = 1, size = 0.4, alpha = 0.75) +
  geom_line(colour = 'dodgerblue2', size = 0.75) +
  scale_x_continuous(limits = c( 0, dim(MOVE_TAB)[1] ), expand = c(0, 0)) +
  scale_y_continuous( limits = c( - max_disp.FD, max_disp.FD), expand = c(0,0) ) +
  ggtitle('FD & DVARS') +
  xlab('time (TRs)') +
  ylab('FD (mm)') + 
  # theme_minimal() +
  theme(axis.line.x      = element_line(size = 0.5, colour = 'black'),
  axis.line.y      = element_line(size = 0.5, colour = 'black'),
  panel.grid.major = element_line(size = 0, colour = 'white'),
  panel.grid.minor = element_line(size = 0, colour = 'white'), 
  plot.title       = element_text(hjust = 0.5),
  axis.title.x     = element_blank(),
  axis.text.x      = element_blank(),
  axis.ticks.x     = element_blank(),
  plot.margin      = unit(c(3,3,4,1), units = 'mm') )

plot_DVARS <- 
  ggplot(mapping = aes(x = 1:dim(MOVE_TAB)[1], y = MOVE_TAB$DVARS) ) +
  geom_line(colour = 'firebrick1', size = 0.75, alpha = 0.8 ) + 
  scale_x_continuous(limits = c( 0, dim(MOVE_TAB)[1] ), expand = c(0, 0)) +
  scale_y_continuous( limits = c(0,max_disp.DVARS), expand = c(0,0) ) + 
  # ggtitle('Framewise Displacement (FD) Across Time') +
  xlab('time (TRs)') +
  ylab(paste0('DVARS ( delta BOLD )')) + 
  # theme_minimal() +
  theme(axis.line.x      = element_line(size = 0.5, colour = 'black'),
  axis.line.y      = element_line(size = 0.5, colour = 'black'),
  panel.grid.major = element_line(size = 0, colour = 'white'),
  panel.grid.minor = element_line(size = 0, colour = 'white'), 
  plot.title       = element_text(hjust = 0.5),
  plot.margin      = unit(c(3,3,4,2), units = 'mm'))

mot_plot <- grid.arrange(plot_FD, plot_DVARS, ncol = 1)

# print(mot_plot)
ggsave(plot = mot_plot, filename = file.path(fig_path, paste0(COND, '_FC_DVARS.pdf') ), units = 'cm', width = 16, height = 17)