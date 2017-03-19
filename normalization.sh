# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
# COND='Retrieval'

SUBJ_DIR=$1
COND=$2
PREPROC=$3

TEMPLATE=$FSLDIR'/data/standard/MNI152_T1_2mm_brain.nii.gz'

mkdir $SUBJ_DIR/anatom/mats
mkdir $SUBJ_DIR/fun/preproc/mats

echo '       + Linear-warping functional to structural...'
flirt -ref $SUBJ_DIR/anatom/brain_Mprage.nii.gz -in $SUBJ_DIR/fun/preproc/mt_$COND -omat $SUBJ_DIR/fun/preproc/mats/func2str.mat -dof 6
echo '       + Linear-warping structural to standard template...'
flirt -ref $TEMPLATE -in $SUBJ_DIR/anatom/brain_Mprage.nii.gz -omat $SUBJ_DIR/anatom/mats/aff_str2std.mat -out $SUBJ_DIR/anatom/l_brain_Mprage
echo '       + Non-linear-warping structural to standard template...'
fnirt --ref=$TEMPLATE --in=$SUBJ_DIR/anatom/brain_Mprage.nii.gz --aff=$SUBJ_DIR/anatom/mats/aff_str2std.mat --iout=$SUBJ_DIR/anatom/nl_brain_Mprage --cout=$SUBJ_DIR/anatom/cout_nl_brain_Mprage # FNIRT strct to std
echo '       + Creating binary mask from non-linearly warped image...'
fslmaths $SUBJ_DIR/anatom/nl_brain_Mprage -bin $SUBJ_DIR/anatom/bin_nl_brain_Mprage
echo '       + Applying standardized warp to functional data...'
applywarp --ref=$TEMPLATE --in=$SUBJ_DIR/fun/preproc/mt_$COND --out=$SUBJ_DIR/fun/preproc/nlmt_$COND --warp=$SUBJ_DIR/anatom/cout_nl_brain_Mprage --premat=$SUBJ_DIR/fun/preproc/mats/func2str.mat
echo '       + Applying spatial smoothing kernel...'
fslmaths $SUBJ_DIR/fun/preproc/nlmt_$COND -kernel gauss 2.54798709 -fmean $SUBJ_DIR/fun/preproc/snlmt_$COND

echo '       + Cleaning up unneeded files...'
rm $SUBJ_DIR/anatom/l_brain_Mprage.nii.gz
rm $SUBJ_DIR/anatom/brain_Mprage_to_MNI152_T1_2mm_brain.log
rm $SUBJ_DIR/fun/preproc/t_$COND.nii*
rm $SUBJ_DIR/fun/preproc/mt_$COND.nii*
rm $SUBJ_DIR/fun/preproc/nlmt_$COND.nii*

echo 'done'
echo '    '