def voxel_size(img, excl_time=True):
    nii = nib.load(img)
    vox_sz = nii.header.get_zooms()

    if excl_time:
        vox_sz=vox_sz[0:3]
    return(vox_sz)