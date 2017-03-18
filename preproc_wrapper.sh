#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -o STD.out
#$ -e STD.err

SUBJ_DIR=$1
COND=$2
PREPROC'/home/hpc3586/brain_state_proj/Preprocessing'
