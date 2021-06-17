def interpret_config(filepath):
    config=open(filepath, "r")
    lines =config.readlines()
    config_dict = {}
        
    for line in lines:
        line=line.strip()
        try:
            key, val = parse_input(line, default_config.keys()) # keywords must be enterest as a list
            config_dict[key] = val
        except:
            print("Error:", line)

    config_dict = check_defaults(config_dict, default_config)
    return(config_dict)