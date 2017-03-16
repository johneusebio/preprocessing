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

radius <- 50 # approximate radius of cortex to skull, in mm

MPEs           <- read.table(file.path(PATH, 'MPEs', paste0(COND, '.1D')))
colnames(MPEs) <- c('roll', 'pitch', 'yaw', 'dS', 'dL', 'dP')


circum <- 2 * pi * radius

for (rot.axis in c('dS', 'dL', 'dP') ) {
  MPEs[, rot.axis] <- circum * ( MPEs[, rot.axis] / 360 )
}

MPEs <-  round(MPEs, digits = 4)

write.table(MPEs, file = file.path(PATH, 'MPEs', paste0('mm_', COND, '.1D')), sep = '  ', row.names = F, col.names = F)

