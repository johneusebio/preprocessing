SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'    # subject directory
COND='Retrieval'

3dTshift -TR 2s -prefix $SUBJ_DIR/fun/preproc/t_$COND $SUBJ_DIR/fun/$COND.nii*

3dAFNItoNIFTI -prefix $SUBJ_DIR/fun/preproc/t_$COND $SUBJ_DIR/fun/preproc/t_$COND+orig.HEAD
rm $SUBJ_DIR/fun/preproc/t_$COND+orig.*