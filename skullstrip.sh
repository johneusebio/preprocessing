# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'

SUBJ_DIR=$1
COND=$2
PREPROC=$3

bet $SUBJ_DIR/anatom/Mprage.nii* $SUBJ_DIR/anatom/brain_Mprage -R