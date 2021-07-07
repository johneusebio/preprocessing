def interpret_input_line(line, keywords):
    input_dict = {}
    items = line.split(",")
    
    for item in items:
        item=item.strip()
        try:
            key, val = parse_input(item, keywords) # keywords must be enterest as a list
            input_dict[key] = val
        except:
            print("Error:", item)

    # check if all files exist 
    if not check_exist(input_dict["FUNC"], "file"):
        raise Exception(input_dict["FUNC"] + " is not a valid filepath.")
    if not check_exist(input_dict["ANAT"], "file"):
        raise Exception(input_dict["ANAT"] + " is not a valid filepath.")
       
    return(input_dict)