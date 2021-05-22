import os
import numpy as np
import pandas as pd
import nibabel as nib
import scipy.stats as stats
from sys import getsizeof
from math import prod, floor
from scipy.spatial.distance import euclidean

def get_niimat(nii):
    x = nib.load(nii)
    return x.get_fdata()

def reshape_4to2(img):
    if len(img.shape) != 4:
        raise Exception("Input must be a 4D array.")
    shape_3d = list(img.shape)
    ntime    = shape_3d.pop(3)
    return np.reshape(img, [prod(shape_3d), ntime], order="F")

def index_4to2(index, orig_sz):
    
    return

def rm_zeroCols(img):
    n_ind = ~(img==0).all(0)
    n_mat = img[:,~(img==0).all(0)]
    return n_mat, n_ind

def voxelwise_fc(img, output, dist=True, step_sz=1000):    
    mat_2d = reshape_4to2(img)
    mat_2d = mat_2d.astype("float32")
    mat_2d = np.transpose(mat_2d)
    mat_2d = stats.zscore(mat_2d, axis=0)
    
    np.nan_to_num(mat_2d, copy=False)

    return
    
def estim_matmb(A, B_dims):
    """
    This function is to get a rough estimate of how large the product of 2 matrices will be.
    """
    sz_ratio = prod([A.shape[1], B_dims[0]]) / prod(A.shape)
    return round(getsizeof(A) * sz_ratio)
    
def get_mem():
    tot_m, used_m, free_m, shared_m, buff_cache, available_m = map(int, os.popen('free --mega -t').readlines()[1].split()[1:])
    return tot_m, used_m, free_m, shared_m, buff_cache, available_m

def det_nrow(A, B, avail_mem):
    """
    This function will determine the number of rows of matrix A to use in the calculation 
    of AB while keeping within memory limitations
    """
        
    max_mb = estim_matmb(A, B.shape)/(10**6)
    if avail_mem/max_mb > 1:
        return A.shape[1]
    else:
        return floor(avail_mem/max_mb * A.shape[0])
        
def array_rmval(x, val=0, axis=0, ind=0):
    if axis not in [0, 1]:
        raise Exception("Selected axis must be either 0 or 1.")
    if axis==1:
        x = np.transpose(x)
    
    keep_ind = x[ind,:] != val
    
    if axis==0:
        return x[keep_ind,:]
    else:
        return np.transpose(x[keep_ind,:])

def mk_fctab(AB, A_range):  
    AB_tab = np.empty((0,3), dtype="float32")
    
    for row in range(AB.shape[0]):
        row_ind = A_range[row]
        col_ind = [row_ind >= x for x in range(AB.shape[1])]
        r_val   = AB[row_ind, col_ind]
        AB_row  = np.vstack([np.repeat(row_ind, len(col_ind)), col_ind, r_val])
        AB_row  = np.transpose(AB_row)
        AB_row  = array_rmval(AB_row, val=0, axis=0, ind=2)
        
        AB_tab  = np.vstack(AB_tab, AB_row)
        
    return AB_tab

def matmul_steps(A,B,row_step):    
    AB_tab = np.empty((0,3), dtype="float32")
    
    cur_row = 0
    while cur_row < A.shape[0]:
        A_range = range(cur_row, cur_row+row_step)
        AB_part = np.matmul(A[A_range,:], B) / (A.shape[1]-1)
        AB_ptab = mk_fctab(AB_part, A_range)
        AB_tab  = np.append(AB_tab, AB_ptab, axis=0) # update this to add to a pre-allocated matrix
        
        cur_row += row_step
    
    return pd.DataFrame(AB_tab, columns=["A_t", "A", "r"])

def matmul_mem(A, B, spare_mem=1024):
    if A.ndim != B.ndim or A.ndim != 2:
        raise Exception("Matrices A and B must be 2-dimensional.")
    
    _, _, free_mem, _, _, _ = get_mem()
    
    avail_mem = free_mem-spare_mem
    row_step  = det_nrow(A, B, avail_mem)
    
    return matmul_steps(A, B, row_step)

def voxel_correl(nii, spare_mem=1024): 
    # spare_mem should be in mb
    img      = get_niimat(nii)
    img_dims = img.shape
    img      = reshape_4to2(img)
    
    # spare_mem *= 976.562
    cor_tab = matmul_mem(np.transpose(img), img, spare_mem=spare_mem)
    del img
    
    # Get original indices 
    A_ind = np.unravel_index(cor_tab[:,0], shape=img_dims[:3], order="F")
    B_ind = np.unravel_index(cor_tab[:,1], shape=img_dims[:3], order="F")
    
    euc_dist = [euclidean(A_ind[ii], B_ind[ii]) for ii in range(A_ind.shape[0])]
    cor_tab["euc_dist"] = euc_dist
    
    return cor_tab