TOP_DIR='/mnt/c/Users/john/Desktop/behav_test'
 
subj_ls=($(ls $TOP_DIR))

for subj in ${subj_ls[@]}; do
	Rscript 2bk_acc.R --PATH=$TOP_DIR/$subj --COND=WorkingMem
done
