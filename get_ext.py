def get_ext(filename):
    filename    =os.path.basename(filename)
    newname, ext=os.path.splitext(filename)
    
    if "." in newname:
        ext = get_ext(newname) + ext
    return(ext)