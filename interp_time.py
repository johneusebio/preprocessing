def interp_time(img, out, int_ind):
    if len(img.shape)!=4:
        raise Exception("Nifti image must have 4 dimensions.")
    
    
    # make blank image
    int_dim = list(img.shape[0:3])
    int_dim.append(int_ind[1]-int_ind[0]-1)
    int_img = np.empty(int_dim)

    int_ind = np.setdiff1d(int_ind, [0, img.shape[3]]).tolist()
        
    for row in range(img.shape[0]):
        for col in range(img.shape[1]):
            for slice in range(img.shape[2]):
                if len(int_ind)==1:
                    int_val = img[row, col, slice, int_ind[0]]
                else:
                    int_val = interp_pts(img[row, col, slice, int_ind[0]], img[row, col, slice, int_ind[1]], int_ind[1]-int_ind[0]-1)
                int_img[row, col, slice, :] = int_val

    return(int_img)
