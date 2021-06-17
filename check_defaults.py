def check_defaults(config_dict, defaults):
    default_keys=[key for key in defaults.keys()]

    restore_defaults=[key not in config_dict.keys() for key in default_keys]
    restore_defaults=list(filter(lambda x: restore_defaults[x], range(len(restore_defaults))))
    restore_defaults=[default_keys[i] for i in restore_defaults]

    for key in restore_defaults:
        config_dict[key] = defaults[key]

    return(config_dict)