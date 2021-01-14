args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--NIFTI') {
    
    nifti_path <- arg[2]
    
  } else if (arg[1] == '--OUTLIERS') {
    
    outliers <- arg[2]
    
  } else if (arg[1] == '--METHOD') {
    
    nifti.crit <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

if (length(unused_args) > 0) {
  print(paste('WARNING: unused arguments ', unused_args))
}

#### data organization ####
outliers <- read.csv(DVARS, header = T)

#### main body ####
nifti.mark     <- which( nifti.crit > 0)
nifti.rm       <- NULL
nifti.interpol <- NULL

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