def cp_rename(filepath, newpath):
    os.system("cp {} {}".format(filepath, newpath))
    return newpath