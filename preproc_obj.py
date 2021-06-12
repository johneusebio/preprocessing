
class Preproc_subj:
    import os
    import pathlib
    import shutil
    import preprocessing as pp
    
    def __init__(self, input, config, step_order):
        # initialize the most current forms of the pp'd data
        self.anat   = input["ANAT"]
        self.func   = input["FUNC"]
        self.out    = input["OUTPUT"]
        self.dirs   = self.dir_ls()
        self.config = config
        self.steps  = {}
        self.step_order = step_order
        
        # create the directory structure for outputting to
        self.create_dirstruct()
        
        # initiate the baseline
        self.pp_baseline()
        self.perform_pp()  # maybe don't include this in the initialization step. Too much at once.
        
    def create_dirstruct(self):
        dirlist=["func", "motion", "spat_norm", "quality_control", ["anat", "segment"]]
        for dir in dirlist:
            dir = self.join_list(dir, self.os.path.sep)
            self.pathlib.Path(self.os.path.join(self.out, dir)).mkdir(parents=True, exist_ok=True)
        return
        
    def dir_ls(self):
        return {
            "anat"   : self.os.path.join(self.out, "anat"),
            "func"   : self.os.path.join(self.out, "func"),
            "norm"   : self.os.path.join(self.out, "spat_norm"),
            "qc"     : self.os.path.join(self.out, "quality_control"),
            "segment": self.os.path.join(self.out, "anat", "segment")
        }
        
    def step__next(self, step_order):
        current_key = self.step__current()
        current_val = step_order[current_key]
        
        next_val = current_val+1
        next_ind = list(step_order.values()).index(next_val)
        return list(step_order.keys())[next_ind]
        
    def step__previous(self):
        current_key = self.step__current()
        current_val = self.step_order[current_key]
        
        next_val = current_val-1
        next_ind = list(self.step_order.values()).index(next_val)
        return list(self.step_order.keys())[next_ind]
        
    def step__current(self):
        done_keys = self.steps.keys()
        done_values = [self.step_order[X] for X in done_keys]
        
        cur_ind = done_values.index(max(done_values))
        return done_keys[cur_ind]
    
    def step__last(self):
        last_val = max(self.step_order.values())
        last_ind = list(self.step_order.keys()).index(last_val)
        return list(self.step_order.keys())[last_ind]
    
    def join_list(self, ls, delim="/"):
        if len(ls) > 1:
            return delim.join(ls)
        return ls
    
    def pp_baseline(self):
        anat_path = self.os.path.join(self.out, "anat", "func.nii.gz")
        func_path = self.os.path.join(self.out, "func", "MPRage.nii.gz")
        
        self.shutil.copyfile(self.anat, anat_path)
        self.shutil.copyfile(self.func, func_path)
        
        self.steps["BASELINE"] = {
            "anat": anat_path,
            "func": func_path
        }
        return
    
    # PREPROCESSING STEPS
    def perform_pp(self):
        last_step = self.step__last()
        while last_step not in list(self.steps.keys()):
            curr_step = self.step__current()
            next_step = self.step__next()
            
    def pp__