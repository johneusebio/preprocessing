args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--PATH') {
    
    PATH <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else if (arg[1] == '--FD') {
    
    thr.FD <- arg[2]
    
  } else if (arg[1] == '--DVARS') {
    
    thr.DVARS <- arg[2]
    
  } else if (arg[1] == '--RM') {
    
    nifti.crit <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

if (length(unused_args) > 0) {
  print(paste('WARNING: unused arguments ', unused_args))
}

#### data organization ####
NIFTI_PATH <- file.path(PATH, 'fun', 'preproc', 'tmp')
NIFTI_LS   <- list.files(NIFTI_PATH, pattern = paste0(COND, '*.nii'), full.names = T)

DVARS <- file.path(PATH, 'mot_analysis', paste0(COND, '_DVARS.csv') )
FD    <- file.path(PATH, 'mot_analysis', paste0(COND, '_FD.csv'   ) )

DVARS <- read.csv(DVARS, header = T)
FD    <- read.csv(FD,    header = T)

#### Test block ####
FD    <- read.csv('C:/Users/john/Documents/sample_fmri/2357ZL/mot_analysis/Retrieval_FD.csv'   , header = T)$FD
DVARS <- read.csv('C:/Users/john/Documents/sample_fmri/2357ZL/mot_analysis/Retrieval_DVARS.csv', header = T)$DVARS
nifti.crit <- 'UNION'
thr.DVARS <- 25
thr.FD    <- 0.1

#### main body ####
DVARS <- c(0, DVARS)

out.FD    <- rep(0, length(FD))
out.FD[which(FD > thr.FD)] <- 1

out.DVARS <- rep(0, length(DVARS))
out.DVARS[which(DVARS > thr.DVARS)] <- 1

out.intersect <- out.DVARS * out.FD
out.union     <- as.numeric(as.logical(out.DVARS + out.FD))

if (nifti.crit == 'UNION') {
  nifti.crit <- out.union
} else if (nifti.crit == 'INTERSECT') {
  nifti.crit <- out.intersect
}

nifti.mark     <- which( nifti.crit > 0)
nifti.rm       <- c()
nifti.interpol  <- c()

COUNT <- 0
for (mark in 1:length(nifti.mark) ) {
  COUNT <- COUNT + 1
  
  if (COUNT > 1) {
    if (nifti.mark[mark - 1] == nifti.mark[mark] - 1) {
      nifti.rm <- c(nifti.rm, nifti.mark[mark])
    }
  }
  
  if (COUNT < length(nifti.mark)) {
    if (nifti.mark[mark + 1] == nifti.mark[mark] + 1) {
      nifti.rm <- c(nifti.rm, nifti.mark[mark])
    }
  }
  
}

nifti.rm       <- unique(nifti.rm)

for (mark in 1:length(nifti.mark)) {
  if (!nifti.mark[mark] %in% nifti.rm) {
    nifti.interpol <- c(nifti.interpol, nifti.mark[mark])
  }
}




