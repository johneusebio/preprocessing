def motcor(img, func_dir, motion_dir):
    motcor_path =os.path.join(func_dir, "m_"+os.path.basename(img))
    _1dfile_path=os.path.join(motion_dir, "motion", "1d_"+rm_ext(os.path.basename(img))+".1D")

    command="3dvolreg -base 0 -prefix {} -1Dfile {} {}".format(motcor_path, _1dfile_path, img)
    os.system(command)

    return(motcor_path, _1dfile_path)