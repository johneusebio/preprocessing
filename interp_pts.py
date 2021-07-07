def interp_pts(start, end, nvals, round=True):
    step_len =(end-start)/(nvals+1)
    interp_set=[start+(step_len*i) for i in range(1,nvals+1)]

    if round:
        interp_set=round_dec(interp_set, [start, end])

    return(interp_set)