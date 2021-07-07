def brainroi(img, out_dir):
    roi_img = os.path.join(out_dir, "roi_"+os.path.basename(img))
    os.system("robustfov -i {} -r {}".format(img, roi_img))

    return(roi_img)