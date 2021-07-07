import os
import gzip
import shutil
import pickle
import decimal
import pathlib
import numpy as np
import pandas as pd
import nibabel as nib
from time import sleep

# Config Defaults
default_config = { 
    "SKULLSTRIP" : "1",
    "SLICETIME"  : "1",
    "MOTCOR"     : "1",
    "NORM"       : "1",
    "SMOOTH"     : "6", # gaussian smoothing kernel size in mm
    "MOTREG"     : "1",
    "GSR"        : "1",
    "NUISANCE"   : "3",
    "TEMPLATE"   : "/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz",
    "SCRUB"      : "UNION" # union, intersect, dvars, fd, none
}

step_order={
    "BASELINE"  :0,
    "SKULLSTRIP":1,
    "SLICETIME" :2,
    "MOTCOR"    :3,
    "NORM"      :4,
    "NUISANCE"  :5,
    "SCRUB"     :6,
    "SMOOTH"    :7
}