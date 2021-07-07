def wrapper_lvl2(input_file, config_file):
    config = interpret_config(config_file)
    input  = interpret_input(input_file)
    nrow   = len(input.index)
    
    for row in range(nrow):
        subj_pp = ppo.Preproc_subj(input.loc[row,:], config, step_order)
        
        with open(os.path.join(subj_pp.out, "steps.p"), "wb") as fp:
            pickle.dump(subj_pp.steps, fp, protocol=pickle.HIGHEST_PROTOCOL)
        with open(os.path.join(subj_pp.out, "config.p"), "wb") as fp:
            pickle.dump(subj_pp.config, fp, protocol=pickle.HIGHEST_PROTOCOL)
        print("")
        
    return