SUBJ_DIR=$1
COND=$2
PREPROC=$3

NUM_CORES=$(grep -c ^processor /proc/cpuinfo)

# if (($NUM_CORES > 1)); then
# 	NUM_CORES=2
# else
# 	NUM_CORES=1
# fi 

3dDeconvolve                                                       \
	-input $SUBJ_DIR/fun/preproc/snlmt_$COND.nii*                                 \
																																	 \
	-num_stimts 6                                                    \
	-stim_file 1 $SUBJ_DIR/MPEs/$COND.1D'[0]' -stim_base 1 -stim_label 1 roll  \
	-stim_file 2 $SUBJ_DIR/MPEs/$COND.1D'[1]' -stim_base 2 -stim_label 2 pitch \
	-stim_file 3 $SUBJ_DIR/MPEs/$COND.1D'[2]' -stim_base 3 -stim_label 3 yaw   \
	-stim_file 4 $SUBJ_DIR/MPEs/$COND.1D'[3]' -stim_base 4 -stim_label 4 dS    \
	-stim_file 5 $SUBJ_DIR/MPEs/$COND.1D'[4]' -stim_base 5 -stim_label 5 dL    \
	-stim_file 6 $SUBJ_DIR/MPEs/$COND.1D'[5]' -stim_base 6 -stim_label 6 dP    \
	                                                                 \
	-fitts $SUBJ_DIR/fun/preproc/fmt_$COND                                                 \
	-errts $SUBJ_DIR/fun/preproc/emt_$COND                                                 \
  # -tout                                                            \
  # -x1D $COND.xmat.1D                                               \
	# -xjpeg $COND.jpg                                                 \
  # -jobs $NUM_CORES

3dAFNItoNIFTI -prefix $SUBJ_DIR/fun/preproc/emt_$COND $SUBJ_DIR/fun/preproc/emt_$COND+*.HEAD
3dAFNItoNIFTI -prefix $SUBJ_DIR/fun/preproc/fmt_$COND $SUBJ_DIR/fun/preproc/fmt_$COND+*.HEAD
rm $SUBJ_DIR/fun/preproc/emt_$COND+*.*
rm $SUBJ_DIR/fun/preproc/fmt_$COND+*.*