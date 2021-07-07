def check_exist(filepath, type="any"):
    # TODO: Simplify with branching `return` statements
    if type in ["file", "f"]:
        from os.path import isfile as exists
    elif type in ["dir", "d"]:
        from os.path import isdir as exists
    elif type=="any":
        from os.path import exists
    else:
        raise Exception("type '" + type + "' is invalid.")

    return(exists(filepath))