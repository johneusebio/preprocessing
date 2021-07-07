def which(list, x=True):
    return [iter for iter, elem in enumerate(list) if elem == x]