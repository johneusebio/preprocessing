SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
COND='Retrieval'

NIFTI_FILE=$SUBJ_DIR/fun/preproc/snlmt_$COND

nvols=$(fslnvols $NIFTI_FILE)

TMP_DIR=$SUBJ_DIR/fun/preproc/.tmp
mkdir $TMP_DIR
fslsplit $NIFTI_FILE $TMP_DIR/$COND'_'

file_ls=($(ls $TMP_DIR/$COND*))
file_ls_num=$((${#file_ls[@]} - 1))

echo 'Computing differences...'
for vol in $(seq 1 1 $file_ls_num); do 
	fslmaths ${file_ls[vol]} -sub ${file_ls[((vol - 1))]} $TMP_DIR/tmp_diff
	fslmaths $TMP_DIR/tmp_diff -sqr $TMP_DIR/sqr_tmp_diff
	echo $(fslmeants -i $TMP_DIR/sqr_tmp_diff -m $SUBJ_DIR/anatom/bin_nl_brain_Mprage.nii.gz) >> $TMP_DIR/DVARS.txt
done

COUNT=1
echo '"deltaTR", "DVARS"' > $TMP_DIR/DVARS.csv
for line in $(cat $TMP_DIR/DVARS.txt); do
	echo '"'TR$(($COUNT + 1))-TR$(($COUNT))'"', $line >> $TMP_DIR/DVARS.csv
	COUNT=$((COUNT + 1))
done

cp -f $TMP_DIR/DVARS.csv $SUBJ_DIR/mot_analysis/
rm -r $TMP_DIR