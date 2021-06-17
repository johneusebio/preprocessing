def nuis_reg(img, _1d, out_dir, pref="nuis", poly="1"):
    clean_img=os.path.join(out_dir, pref + "_" + rm_ext(img) + ".nii.gz")
    command="3dDeconvolve -input {} -ortvec  {} {} -polort {} -errts {}".format(img, _1d, pref, poly, clean_img)
    os.system(command)

    return(clean_img)