# PREPROC='/mnt/c/Users/john/OneDrive/2017-2018/preprocessing' # directory of preproc scripts
# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
# COND='Retrieval'																				
																												
SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
					         # NOTE: must use this name for behav & fmri data
PREPROC=$3


mkdir $SUBJ_DIR/fun/preproc
NIFTI_file=$SUBJ_DIR/fun/preproc/t_$COND.nii*

3dvolreg -base 0 -prefix $SUBJ_DIR/fun/preproc/mt_$COND -1Dfile $SUBJ_DIR/MPEs/$COND.1D $NIFTI_file
3dAFNItoNIFTI -prefix $SUBJ_DIR/fun/preproc/mt_$COND $SUBJ_DIR/fun/preproc/mt_$COND+orig.HEAD
rm $SUBJ_DIR/fun/preproc/mt_$COND+orig.*

Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND