def bin_mask(mask, thr=0.5):
    output = os.path.join(os.path.dirname(mask), "bin_"+os.path.basename(mask))
    command="fslmaths {} -thr {} -bin {}".format(mask, thr, output)
    os.system(command)
    
    return(output)