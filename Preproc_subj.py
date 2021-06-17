
class Preproc_subj:
    import os
    import pathlib
    import shutil
    import preprocessing as pp
    import statistics as stats
    
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
        
    def pp_switcher(self, pp_step):
        switcher = {
            "SKULLSTRIP" : self.pp__skullstrip,
            "SLICETIME"  : self.pp__slicetime,
            "MOTCOR"     : self.pp__motcor,
            "NORM"       : self.pp__spatnorm,
            "SMOOTH"     : self.pp__smooth,
            "NUISANCE"   : self.pp__nuisreg,
            "SCRUB"      : self.pp__scrub
        }
        pp_func = switcher.get(pp_step, lambda: "Invalid step")
        pp_func()
    
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
            "motion" : self.os.path.join(self.out, "motion"),
            "norm"   : self.os.path.join(self.out, "spat_norm"),
            "qc"     : self.os.path.join(self.out, "quality_control"),
            "segment": self.os.path.join(self.out, "anat", "segment")
        }
        
    def step__next(self):
        current_key = self.step__current()
        current_val = self.step_order[current_key]
        
        next_val = current_val+1
        next_ind = list(self.step_order.values()).index(next_val)
        return list(self.step_order.keys())[next_ind]
        
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
    
    def csf_tcourse(self):
        csf_mask = self.pp.segment(self.anat, self.dirs["segment"])
        csf_mask = self.pp.bin_mask(csf_mask, 0.75)

        return self.pp.roi_tcourse(
            self.func,
            csf_mask,
            self.os.path.join(self.dirs["motion"], "global_signal.1D"),
        )
    
    def outliers__fd(self):
        print("       + Frame-wise Displacement...")
        vox_sz = self.pp.voxel_size(self.steps["BASELINE"]["func"])
        return self.pp.fd_out(self.steps["BASELINE"]["func"], self.stats.mean(vox_sz), self.dirs["motion"])
    
    def outliers__dvars(self):
        print("       + DVARS...")
        nomoco = "MOTCOR" in list(self.steps.keys())
        dvars_func = self.func if nomoco else self.steps["BASELINE"]["func"]
        return self.pp.meantsBOLD(dvars_func, self.dirs["motion"], nomoco)
    
    # PREPROCESSING STEPS
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
    
    def perform_pp(self):
        # update this to use cases
        last_step = self.step__last()
        while last_step not in list(self.steps.keys()):
            # curr_step = self.step__current()
            next_step = self.step__next()
            
            self.pp_switcher(next_step)
            
    def pp__skullstrip(self):
        print("SKULL STRIPPING")
        self.func = self.pp.skullstrip(self.func, self.dirs["func"])
        self.steps["SKULLSTRIP"] = {
            "func": self.func,
            "anat": self.anat
        }
    
    def pp__slicetime(self):
        print("SLICETIME CORRECTION")
        self.func = self.pp.slicetime(self.func, self.dirs["func"])
        self.steps["SKULLSTRIP"] = {
            "func": self.func,
            "anat": self.anat
        }
    
    def pp__motcor(self):
        print("MOTION CORRECTION")
        self.func, _1d_filepath = self.pp.motcor(self.func, self.dirs["func"], self.dirs["motion"])
        self.steps["MOTCOR"] = {
            "func"     : self.func,
            "anat"     : self.anat,
            "mot_estim": _1d_filepath
        }
        
    def pp__spatnorm(self):
        print("SPATIAL NORMALIZATION")
        self.anat, self.func, nl_warp, nl_premat = self.pp.spatnorm(self.func, self.anat, self.config["TEMPLATE"], self.dirs["func"], self.dirs["anat"], self.dirs["norm"])
        self.steps["NORM"] = {
            "func"     : self.func,
            "anat"     : self.anat,
            "nl_warp"  : nl_warp,
            "nl_premat": nl_premat
        }
    
    def pp__nuisreg(self):
        print("NUISANCE SIGNAL REGRESSION")
        nuis_path = self.os.path.join(self.dirs["motion"], "nuisance_regressors.1D")
        
        csf_tcourse=None
        mot_tcourse=None
        
        if self.config["GSR"] == 1:
            csf_tcourse = self.csf_tcourse()
        if self.config["MOTREG"] == 1:
            mot_tcourse = self.steps["MOTCOR"]["mot_estim"]
        
        _ = self.pp.combine_nuis(csf_tcourse, mot_tcourse, nuis_path)
        self.func = self.pp.nuis_reg(self.func, nuis_path, self.dirs["func"], poly=self.config["NUISANCE"])
        self.steps["NUISANCE"] = {
            "anat"    : self.anat,
            "func"    : self.func,
            "gs_reg"  : csf_tcourse,
            "mot_reg" : mot_tcourse,
            "nuis_reg": nuis_path
        }
    
    def pp__smooth(self):
        print("SPATIAL SMOOTHING")
        self.func = self.pp.spat_smooth(self.func, self.config["SMOOTH"], self.dirs["func"])
        self.steps["SMOOTH"] = {
            "func": self.func,
            "anat": self.anat
        }
    
    def pp__scrub(self):
        print("SCRUBBING fMRI TIME SERIES")
        
        out_fd    = None
        out_dvars = None
        if self.config["SCRUB"] in ["UNION", "INTERSECT", "FD"]:
            out_fd    = self.outliers__fd()
        if self.config["SCRUB"] in ["UNION", "INTERSECT", "DVARS"]:
            out_dvars = self.outliers__dvars()
        
        out_scrub = self.pp.mk_outliers(out_dvars, out_fd, self.dirs["motion"], method=self.config["SCRUB"])
        self.func = self.pp.scrubbing(self.func, out_scrub, self.dirs["func"], interpolate=True)
        self.steps["SCRUB"] = {
            "func": self.func,
            "anat": self.anat,
            "out_scrub": out_scrub,
            "out_fd": out_fd,
            "out_dvars": out_dvars,
            "method": self.config["SCRUB"]
        }