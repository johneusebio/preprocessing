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
print('scrubbing the time series....')
NIFTI_PATH <- file.path(PATH, 'fun', 'preproc', 'tmp')
NIFTI_LS   <- list.files(NIFTI_PATH, pattern = paste0(COND, '*.nii*'), full.names = T)
print(NIFTI_LS)
print(paste0('number of NIFTI files is ', length(NIFTI_LS) ) )

print('line 41, scrubbing')
DVARS <- file.path(PATH, 'mot_analysis', paste0(COND, '_DVARS.csv') )
print('line 42, scrubbing')
FD    <- file.path(PATH, 'mot_analysis', paste0(COND, '_FD.csv'   ) )

DVARS <- read.csv(DVARS, header = T)
FD    <- read.csv(FD,    header = T)

#### Test block ####
# FD    <- read.csv('C:/Users/john/Documents/sample_fmri/2357ZL/mot_analysis/Retrieval_FD.csv'   , header = T)$FD
# DVARS <- read.csv('C:/Users/john/Documents/sample_fmri/2357ZL/mot_analysis/Retrieval_DVARS.csv', header = T)$DVARS
# nifti.crit <- 'UNION'
# thr.DVARS <- 25
# thr.FD    <- 0.1

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

#### interpolation ####

for (nifti in nifti.interpol) {
  cmd.interpol.sum <- paste0('fslmaths ', NIFTI_LS[nifti - 1], ' -add ', NIFTI_LS[nifti - 1], ' ', NIFTI_LS[nifti])
  cmd.interpol.avg <- paste0('fslmaths ', NIFTI_LS[nifti], ' -div 2', NIFTI_LS[nifti])
  system(cmd.interpol.sum, wait = T)
  system(cmd.interpol.avg, wait = T)
}

#### remove outlier TRs ####

for (nifti in nifti.rm) {
  file.remove(NIFTI_LS[nifti])
}

#### merge remaining TRs ####

cmd.tr    <- paste0('3dinfo -tr ', PATH, '/fun/', COND, '.nii*')
TR        <- system(cmd.tr, intern = T, wait = T)

cmd.merge <- paste0('fslmerge -t ', 
                    paste0(PATH, '/fun/preproc/scrub_snlmt_', COND), 
                    ' ', 
                    paste0(PATH, '/fun/preproc/tmp/*', COND, '.nii*'),
                    ' ', 
                    TR)


system(cmd.merge, wait = T)

if ( length(NIFTI_LS) > 0 ) {
  system(paste0('rm -r ', PATH, '/fun/preproc/tmp'))
}

