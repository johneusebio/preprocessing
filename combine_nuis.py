def combine_nuis(nuis1, nuis2, output):
    if nuis1 is None:
        nuis2_pd=pd.read_csv(nuis2, sep="\s+", header=None)
        nuis2_pd.to_csv(output, sep="\t", header=None, index=False)
        return(output)
    elif nuis2 is None:
        nuis1_pd=pd.read_csv(nuis1, sep="\s+", header=None)
        nuis1_pd.to_csv(output, sep="\t", header=None, index=False)
        return(output)

    nuis1_pd=pd.read_csv(nuis1, sep="\s+", header=None)
    nuis2_pd=pd.read_csv(nuis2, sep="\s+", header=None)

    nuis_cbind = pd.concat([nuis1_pd, nuis2_pd], axis=1)
    nuis_cbind.to_csv(output, sep="\t", header=None, index=False)

    return(output)