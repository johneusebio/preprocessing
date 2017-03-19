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

require('R.matlab', quietly = T, warn.conflicts = F)

# PATH <- 'C:/Users/john/Desktop/2357ZL'
# COND <- 'WorkingMem'

out_path <- file.path(PATH, 'behav', 'summ_stats')
dir.create(out_path)

subj_nm <- basename(PATH)
behav   <- readMat(file.path(PATH, 'behav', paste0(subj_nm, '_', COND, '.mat') ))

behav.data <- as.data.frame(behav$rec)
colnames(behav.data) <- unlist(behav$p[[13]])
behav.2bk <- behav.data[which(behav.data$iCond == 2), ]

behav.acc <- sum(behav.2bk$respCorrect, na.rm = T) / dim(behav.2bk)[1]
behav.vel <- mean(behav.2bk$RT[which(behav.2bk$respCorrect == 1)]) * 1000

behav.summ <- data.frame(acc = behav.acc, RT = behav.vel)

write.csv(behav.summ, file.path(out_path, paste0(COND, '.csv') ), row.names = F)