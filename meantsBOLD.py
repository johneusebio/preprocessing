def meantsBOLD(img, outdir, nomoco):
    dvars_txt = os.path.join(outdir, "dvars.1D")
    dvars_png = os.path.join(outdir, "dvars.png")

    out_compound = os.path.join(outdir, "dvars_outCols.1D")
    out_outliers = os.path.join(outdir, "dvars_outliers.1D")

    command="fsl_motion_outliers -i {} -o {} -s {} -p {} --dvars".format(img, out_compound, dvars_txt, dvars_png)
    if nomoco:
        command+=" --nomoco"

    os.system(command)

    sleep(10)
    if not os.path.exists(out_compound):
        nlines=file_len(dvars_txt)
        dvars_compound=np.zeros([nlines,1], dtype=int)
        dvars_compound=pd.DataFrame(dvars_compound)
        dvars_compound.to_csv(out_compound, sep="\t", index=False, header=False)

    dvars_out=pd.read_csv(out_compound, delim_whitespace=True, header=None)
    dvars_out=dvars_out.sum(axis=1)
    dvars_out=dvars_out.astype("int")
    dvars_out.to_csv(out_outliers, sep="\t", index=False, header=False)

    return(out_outliers)