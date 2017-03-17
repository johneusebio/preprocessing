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

meantsBOLD <- read.table( file.path(PATH, 'mot_analysis', paste0(COND, '_meantsBOLD.txt')) )

DVARS <- NULL
for ( row in 1:dim(meantsBOLD)[1] ) {
  delta_I <- meantsBOLD[row, 1] - meantsBOLD[row - 1 , 1]
  
}


