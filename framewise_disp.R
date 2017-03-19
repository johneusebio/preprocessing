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

# PATH <- '/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
# COND <- 'Retrieval'

library(ggplot2)

output_path <- file.path(PATH, 'mot_analysis')
fig_path    <- file.path(output_path, 'plots')
dir.create(fig_path, recursive = T, showWarnings = F)

head_rad   <- 50 # distance from center for brain to cortex, in mm
sys_cmd    <- paste0('3dinfo -adi -adj -adk ', file.path(PATH, 'fun', 'preproc'),  '/snlmt_', COND, '.nii*' )

voxel_size <- system(sys_cmd, intern = T)
voxel_size <- strsplit(voxel_size, split = '\t')[[1]]
voxel_size <- as.numeric(voxel_size)
voxel_size <- min(voxel_size)

mpe_mm <- read.table( file.path( PATH, 'MPEs', paste0('mm_', COND, '.1D') ) )
colnames(mpe_mm) <- c('roll', 'pitch', 'yaw', 'mmS', 'mmL', 'mmP')

nrows <- dim(mpe_mm)[1]

cFD   <- NULL
for (row in 1:nrows) {
  if (row == 1) {
    cFD <- 0
    next
  }
  FD  <- sum(mpe_mm[row - 1 ,] - mpe_mm[row,])
  cFD <- c( cFD, FD )
}

cFD <- data.frame(
  TR = c(1:length(cFD)), 
  FD = abs(cFD)
  )

max_disp.FD    <- c(0.5 * voxel_size * 360 / (2 * pi * head_rad), 0.5 * voxel_size)
max_disp.FD    <- max( max_disp.FD )
if( max( abs(cFD$FD) ) > max_disp.FD ) {
  max_disp.FD  <- max( max( abs(cFD$FD) ) )
}
max_disp.scale <- 1

plot_FD <- ggplot(mapping = aes(x = cFD$TR, y = cFD$FD)) + 
  geom_line(colour = 'dodgerblue2', size = 0.75) +
  scale_x_continuous(limits = c( 0, dim(cFD)[1] )) +
  scale_y_continuous( limits = c(-max_disp.FD, max_disp.FD)) + 
  ggtitle('Framewise Displacement (FD) Across Time') +
  xlab('time (TRs)') +
  ylab('FD (mm)') + 
  theme_minimal() +
  theme(axis.line.x = element_line(size = 0.5, colour = 'black'),
  axis.line.y       = element_line(size = 0.5, colour = 'black'),
  panel.grid.major  = element_line(size = 0, colour = 'white'),
  panel.grid.minor  = element_line(size = 0, colour = 'white'),
  plot.title        = element_text(hjust = 0.5))

write.csv(cFD, file = file.path(output_path, paste0(COND, '_FD.csv')), row.names = F)
ggsave(plot = plot_FD, filename = file.path(fig_path, paste0(COND, '_FD.pdf') ), units = 'cm', width = 16, height = 9)
