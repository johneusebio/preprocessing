def skullstrip(img, out_dir):
    out_dir  = os.path.join(out_dir, "anat")
    out_file = "brain_" + rm_ext(img)
    skullstr = os.path.join(out_dir, out_file)

    command="bet {} {} -R".format(img, skullstr)
    os.system(command)
    
    return(skullstr)