def applywarp(in_img, out_img, ref_img, warp_img, premat):
    os.system("fnirt --ref={} --in={} --aff={} --iout={} --cout={} --subsamp=2,2,2,1".format(ref_img, in_img, premat, out_img, warp_img))
    return(out_img)