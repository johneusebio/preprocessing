def spat_smooth(img, mm, out_dir): 
    sigma=gauss_mm2sigma(mm)
    s_img=os.path.join(out_dir, "s_"+os.path.basename(img))
    
    command="fslmaths {} -kernel gauss {} -fmean {}".format(img, sigma, s_img)
    os.system(command)
    
    return(s_img)