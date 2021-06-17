def scrubbing(nifti, outliers, out_dir, interpolate=False):
    img = nib.load(nifti)
    mat = img.get_fdata()

    outliers=pd.read_csv(outliers, delimiter="\t", header=None)
    outliers=outliers.values.tolist()
    outliers=which([o[0] for o in outliers], 1)

    print("       + Removing outlier timepoints...")
    mat[:,:,:,outliers]=float("NaN")

    if interpolate:
        print("       + Linearly-interpolating outliers...")
        sub_ind = surrounding_timepoints(range(mat.shape[3]), outliers)

        for oo in range(len(sub_ind)):
            tmp = interp_time(mat, outliers[oo], sub_ind[oo,:])
            mat[:,:,:,(sub_ind[oo,0]+1):sub_ind[oo,1]] = tmp
    
    # TODO: move bellow to a new function
    new_img = nib.Nifti1Image(mat, img.affine, header=img.header)
    print("       + Saving scrubbed timeseries...")
    scrub_path=os.path.join(out_dir, "scrub_"+rm_ext(os.path.basename(nifti))+".nii.gz")
    nib.save(new_img, scrub_path)
    
    return(scrub_path)