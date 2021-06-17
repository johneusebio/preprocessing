def slicetime(img, out_dir):
    tr=getTR(img)
    tshift_path=os.path.join(out_dir, "func", "t_" + rm_ext(img)+".nii.gz")
    
    command="3dTshift -TR {}s -prefix {} {}".format(tr, tshift_path, img)
    os.system(command)

    return(tshift_path)