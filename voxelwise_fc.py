import numpy as np
import nibabel as nib
import matplotlib.pyplot as plt
from os import mkdir
from nilearn import datasets, plotting
from os.path import join, isfile, isdir
from nilearn.input_data import NiftiMapsMasker
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
        return datasets.fetch_atlas_msdl()
    if not isfile(atlas):
        raise Exception("Must provide a valid atlas file path or leave it blank.")
    labels = auto_labels(atlas) if labels is None else load_labels(labels)
    if rois is None:
        raise Exception("Must provide roi coordinates.")
    else:
        rois=load_coords(rois)
    return {"maps": atlas, "labels": labels, "rois": rois}

def t_series(nifti, atlas):
    atlas_filename = atlas["maps"]
    
    masker = NiftiMapsMasker(maps_img=atlas_filename, standardize=True, memory="nilearn_cache")
    return masker.fit_transform(nifti)
    
def fc_mat(nifti, atlas):
    roi_t = t_series(nifti, atlas)
    correlation_measure = ConnectivityMeasure(kind="correlation")
    return correlation_measure.fit_transform([roi_t])[0]

def euc_dist(a,b):
    return np.linalg.norm(a-b)

def fcmat__plot(mat, atlas_labels, savepath):
    fig = plt.figure(figsize=(10,10))
    np.fill_diagonal(mat, 0)
    plotting.plot_matrix(mat, labels=atlas_labels, colorbar=True, vmax=0.8, vmin=-0.8, figure=fig)
    fig.savefig(savepath)
    return

def connectome__plot(mat, region_coords, savepath):
    fig = plt.figure(figsize=(10,10))
    plotting.plot_connectome(mat, region_coords, edge_threshold="80%", colorbar=True, figure=fig)
    fig.savefig(savepath)
    return
    
def r_x_dist__plot(r, dist, savepath):
    fig = plt.figure(figsize=(20,10))
    ax  = fig.add_axes([0.05,0.05,.9,.9])
    ax.scatter(dist, r, color="black")
    ax.axhline(y=0, color="r", linestyle="dashed")
    ax.set_xlabel("Euclidean Distance Between ROIs (vox)")
    ax.set_ylabel("Correlation (r)")
    ax.set_title("FC as a Function of Euclidean Distance Between ROIs")
    fig.savefig(savepath)
    return
    
def r_x_dist(mat, coords):
    n_utri = int(mat.shape[0]*(mat.shape[1]-1)/2)
    
    r_tab    = np.zeros([n_utri])   # contains the correlation (r) between rois A & B
    a_tab    = np.zeros([n_utri,3]) # contains the coordinates of roi A (rows)
    b_tab    = np.zeros([n_utri,3]) # contains the coorindates of roi B (columns)
    dist_tab = np.zeros([n_utri])   # contains the Euclidean distance between rois A & B
    
    count=0
    for rr in range(mat.shape[0]):
        for cc in range(mat.shape[1]):
            if rr >= cc:
                continue
            r_tab   [count]  = mat[rr,cc]
            a_tab   [count,] = list(coords[rr])
            b_tab   [count,] = list(coords[cc])
            dist_tab[count]  = abs(euc_dist(a_tab[count,], b_tab[count,]))
            
            count+=1
    return r_tab, a_tab, b_tab, dist_tab
    
def qc_fc(nifti, atlas=None, labels=None, rois=None, plot_dir=None):
    dataset = load_atlas(atlas=atlas, labels=labels, rois=rois)
    
    r_mat   = fc_mat(nifti, dataset)
    r_tab, a_tab, b_tab, dist_tab = r_x_dist(r_mat, dataset.region_coords)

    if plot_dir is not None:
        if not isdir(plot_dir):
            mkdir(plot_dir)
        connectome__plot(r_mat, dataset.region_coords, join(plot_dir, "QC_connectome.png"))
        fcmat__plot(r_mat, dataset.labels, join(plot_dir, "QC_fcmat.png"))
        r_x_dist__plot(r_tab, dist_tab, join(plot_dir, "QC_r_x_dist.png"))
    return r_mat, r_tab, a_tab, b_tab, dist_tab