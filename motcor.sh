PREPROC='/mnt/c/Users/john/OneDrive/2017-2018/preprocessing' # directory of preproc scripts

SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'    # subject directory
COND='Retrieval'																						 # name of condition
																																	# NOTE: must use this name for behav & fmri data


mkdir $SUBJ_DIR/fun/preproc
NIFTI_file=$SUBJ_DIR/fun/preproc/t_$COND+orig.HEAD

3dvolreg -base 0 -prefix fun/preproc/mt_$COND -1Dfile MPEs/$COND.1D $NIFTI_file

Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND