import numpy as np
from sklearn.cluster import KMeans

def dim_4to2(mat, order="F"):
    if len(mat.shape)!=4:
        raise Exception("Input matrix must be 4D.")
    nrow = mat.shape[:3]
    ncol = mat.shape[3]
    return np.reshape(mat, [nrow, ncol], order=order)

def kmeans(mat, k, seed=None, var_explained=False):
    km = KMeans(n_clusters=k, random_state=seed)
    km.fit(mat)
    y_kmeans = km.predict(mat)
    
    if var_explained:
        return y_kmeans, km, kmeans__SS(mat, km, y_kmeans)
    return y_kmeans, km
    

def euc_dist(a,b):
    return np.linalg.norm(a-b)
    
def kmeans__SS(X, kmeans_obj, clus_id):
    return sum(
        euc_dist(X[pt, :], kmeans_obj.cluster_centers_[clus_id[pt]]) ** 2
        for pt in range(X.shape[0])
    )
