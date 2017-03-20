#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be

SUBJ_DIR=$1
COND=$2
FD=$3
DVARS=$4
RM=$5
PREPROC='/mnt/c/Users/john/OneDrive/2017-2018/preprocessing'

bash $PREPROC/skullstrip.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/slicetime.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/motcor.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/normalization.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/motreg.sh $SUBJ_DIR $COND $PREPROC
Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND
Rscript $PREPROC/framewise_disp.R --PATH=$SUBJ_DIR --COND=$COND
bash $PREPROC/meantsBOLD.sh $SUBJ_DIR $COND $PREPROC
Rscript $PREPROC/multiplot.R --PATH=$SUBJ_DIR --COND=$COND
Rscript $PREPROC/mot_summ.R --PATH=$SUBJ_DIR --COND=$COND
Rscript $PREPROC/scrubbing.R --PATH=$SUBJ_DIR --COND=$COND --FD=$FD --DVARS=$DVARS --RM=$RM