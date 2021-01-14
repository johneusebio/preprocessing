args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  
  if (arg[1] == '--OUT_DIR') {
    
    OUT_DIR <- arg[2]
    
  } else if (arg[1] == "--MPE_MM") {

    MPE_MM <- arg[2]

  } else if (arg[1] == "--VOXEL_DIM") {

    VOXEL_DIM <- arg[2]

  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

if (length(unused_args) > 0) {
  print(paste('WARNING: unused arguments ', unused_args))
}

library(ggplot2)

head_rad   <- 50 # distance from center for brain to cortex, in mm

voxel_size <- strsplit(VOXEL_DIM, split = '\\s+')[[1]]
voxel_size <- as.numeric(voxel_size)
voxel_size <- min(voxel_size)

mpe_mm <- read.table(MPE_MM)
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
max_disp.FD    <- max(voxel_size)
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

write.csv(cFD, file = file.path(OUT_DIR, 'motion_FD.csv'), row.names = F)
ggsave(plot = plot_FD, filename = file.path(OUT_DIR, 'motion_FD.pdf'), units = 'cm', width = 16, height = 9)