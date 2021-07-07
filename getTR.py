def getTR(filepath):    
    img = nib.load(filepath)
    tr  = img.header.get_zooms()[3]
    return(str(tr)) 