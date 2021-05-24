from os import removedirs
import numpy as np
import nibabel as nib
from os.path import isfile
from nilearn import datasets, plotting
from nilearn.input_data import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure

def auto_labels(nifti):
    nii = nib.load(nifti)
    nii = nii.get_fdata()
    lab = (np.unique(nii)).astype("int")
    lab = lab[lab != 0]
    
    return lab.astype("str")

def load_labels(csv_path):
    labels = np.genfromtxt(csv_path, delimiter=',', dtype="str")
    if labels.ndim != 1:
        raise Exception("labels must be a 1-D file (i.e., single-column)")
    return list(labels)

def load_coords(csv_path):
    coords = np.genfromtxt(csv_path, delimiter=',')
    if coords.ndim != 2:
        raise Exception("Coords must be a 2-D file")
    if coords.shape[1] != 3:
        raise Exception("Coords must have 3 columns")
    return coords
    
def load_atlas(atlas=None, labels=None, rois=None):
    if atlas is None:
        return datasets.fetch_coords_seitzman_2018(ordered_regions=True)
    if not isfile(atlas):
        raise Exception("Must provide a valid atlas file path or leave it blank.")
    labels = auto_labels(atlas) if labels is None else load_labels(labels)
    if rois is None:
        raise Exception("Must provide roi coordinates.")
    else:
        rois=load_coords(rois)
    return {"maps": atlas, "labels": labels, "rois": rois}

def t_series(nifti, atlas):
    masker = NiftiLabelsMasker(labels_img=atlas)
    return masker.fit(nifti)
    
def fc_mat(nifti, atlas):
    roi_t = t_series(nifti, atlas)
    correlation_measure = ConnectivityMeasure(kind="correlation")
    return correlation_measure.fit_transform([roi_t])[0]

def plot_fc(mat, atlas):    
    mat=np.fill_diagonal(mat, 0)
    plt_mat=plotting.plot_matrix(mat, labels=atlas["labels"], colorbar=True, vmax=0.8, vmin=-0.8)
    plt_con=plotting.plot_connectome(mat, atlas["rois"], edge_threshold="80%", colorbar=True)
    return plt_mat, plt_con
    
def euc_dist(a, b, abs=True):
    if abs:
        return abs(np.linalg.norm(a-b))
    else:
        return np.linalg.norm(a-b)
        
def qc_fc(nifti, atlas=None, labels=None, rois=None, plot_path=None):
    dataset = load_atlas(atlas=atlas, labels=labels, rois=rois)
    r_mat   = fc_mat(nifti, atlas)
    
    
    if plot_path is not None:
        plt_mat, plt_con = plot_fc(r_mat, dataset)
    
    
    
    return