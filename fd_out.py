def fd_out(img, voxel_size, outdir):
    thresh = voxel_size/2
    fd_txt = os.path.join(outdir, "fd.1D")
    fd_png = os.path.join(outdir, "fd.png")

    out_compound = os.path.join(outdir, "fd_outCols.1D")
    out_outliers = os.path.join(outdir, "fd_outliers.1D")

    command = "fsl_motion_outliers -i {} -o {} -s {} -p {} --fd --thresh={}".format(img, out_compound, fd_txt, fd_png, thresh)
    os.system(command)

    sleep(10)
    if not os.path.exists(out_compound):
        nlines=file_len(fd_txt)
        fd_compound=np.zeros([nlines,1], dtype=int)
        fd_compound=pd.DataFrame(fd_compound)
        fd_compound.to_csv(out_compound, sep="\t", index=False, header=False)

    fd_out=pd.read_csv(out_compound, delim_whitespace=True, header=None)
    fd_out=fd_out.sum(axis=1)
    fd_out=fd_out.astype("int")

    fd_out.to_csv(out_outliers, sep="\t", index=False, header=False)

    return(out_outliers)