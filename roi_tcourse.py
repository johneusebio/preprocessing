def roi_tcourse(img, mask, save_path):
    # compute the mean time course for ROI
    command="fslmeants -i '{}' -m '{}' -o '{}'".format(img, mask, save_path)
    os.system(command)
    
    return(save_path)