def n_dec(val):
    return abs(decimal.Decimal(str(val)).as_tuple().exponent)