def spatnorm(f_img, a_img, template, func_dir, anat_dir, norm_dir):
    # lin warp func to struct
    print("       + Linear-warping functional to structural...")
    l_func_omat=os.path.join(norm_dir, "func2str.mat")
    command="flirt -ref {} -in {} -omat {} -dof 6".format(a_img, f_img, l_func_omat)
    os.system(command)
    
    # lin warp struct to template
    print("       + Linear-warping structural to standard template...")
    l_anat_img =os.path.join(anat_dir, "l_" + os.path.basename(a_img))
    l_anat_omat=os.path.join(norm_dir, "aff_str2std.mat")
    command="flirt -ref {} -in {} -omat {} -out {}".format(template, a_img, l_anat_omat, l_anat_img)
    os.system(command)
    
    # non-lin warp struct to template
    print("       + Non-linear-warping structural to standard template...")
    nl_anat_img  =os.path.join(anat_dir, "n" + os.path.basename(l_anat_img))
    cout_anat_img=os.path.join(anat_dir, "cout_" + os.path.basename(nl_anat_img))
    command="fnirt --ref={} --in={} --aff={} --iout={} --cout={} --subsamp=2,2,2,1".format(template, a_img, l_anat_omat, nl_anat_img, cout_anat_img)
    os.system(command)
    
    # make binary mask from non-lin warped image
    print("       + Creating binary mask from non-linearly warped image...")
    bin_nl_anat_img=os.path.join(anat_dir, "bin_" + os.path.basename(nl_anat_img))
    command="fslmaths {} -bin {}".format(nl_anat_img, bin_nl_anat_img)
    os.system(command)
    
    # apply std warp to func data
    print("       + Applying standardized warp to functional data...")
    nl_func_img=os.path.join(func_dir, "nl_"+os.path.basename(f_img))
    command="applywarp --ref={} --in={} --out={} --warp={} --premat={}".format(template, f_img, nl_func_img, cout_anat_img, l_func_omat)
    os.system(command)

    # create tempalte mask
    print("       + Creating binary template mask...")
    mask_path=os.path.join(anat_dir, "mask_" + os.path.basename(template))
    command="fslmaths {} -bin {}".format(template, mask_path)
    os.system(command)

    return(nl_anat_img, nl_func_img, cout_anat_img, l_anat_omat) # anat, func, warp, premat