# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'    # subject directory
# COND='Retrieval'

SUBJ_DIR=$1
COND=$2

TR=$(3dinfo -tr $SUBJ_DIR/fun/$COND.nii*)

3dTshift -TR $TR's' -prefix $SUBJ_DIR/fun/preproc/t_$COND $SUBJ_DIR/fun/$COND.nii*

3dAFNItoNIFTI -prefix $SUBJ_DIR/fun/preproc/t_$COND $SUBJ_DIR/fun/preproc/t_$COND+orig.HEAD
rm $SUBJ_DIR/fun/preproc/t_$COND+orig.*