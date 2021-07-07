def round_dec(vals, ref):
    n_places = max(n_dec(i) for i in ref)
    return [round(i, n_places) for i in vals]