def segment(img, out_dir=None):
    if out_dir is None:
        out_dir = os.path.dirname(img)
    seg_path = os.path.join(out_dir, "seg")
    command="fast -n 3 -t 1 -o '{}' '{}'".format(seg_path, img)
    os.system(command)

    return(seg_path)