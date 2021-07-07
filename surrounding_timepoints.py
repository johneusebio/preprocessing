def surrounding_timepoints(t_range, ind):   
    sub_ind = np.empty((0,2), dtype=int, order='C')
    
    for ii in ind:
        t_start = ii-1
        t_end   = ii+1
        
        while t_start in ind:
            t_start -= 1
        while t_end in ind:
            t_end += 1
        
        if t_start < min(t_range):
            t_start = "NaN"
        if t_end < min(t_range):
            t_end = "NaN"
        
        sub_ind = np.vstack([sub_ind, (t_start, t_end)])
        sub_ind = np.unique(sub_ind, axis=0)
    return(sub_ind)