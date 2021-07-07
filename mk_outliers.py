def mk_outliers(dvars, fd, out_dir, method="UNION"):
    if fd is not None:
        fd_mat = pd.read_csv(fd, delimiter="\t", header=None)
    if dvars is not None:
        dvars_mat = pd.read_csv(dvars, delimiter="\t", header=None)
    
    if method=="UNION":
        outliers_mat = (fd_mat + dvars_mat).astype("bool")
        outliers_mat = outliers_mat.astype("int")
    elif method=="INTERSECT":
        outliers_mat = dvars_mat[0]*fd_mat[0]
        outliers_mat = outliers_mat.dropna()
    elif method=="FD":
        outliers_mat = fd_mat
    elif method=="DVARS":
        outliers_mat = dvars_mat
    
    outlier_path = os.path.join(out_dir, "scrub_outliers.txt")
    outliers_mat.to_csv(outlier_path, sep="\t", index=False, header=False)

    return(outlier_path)