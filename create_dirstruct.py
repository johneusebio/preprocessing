def create_dirstruct(output):
    pathlib.Path(os.path.join(output, "func"           )).mkdir(parents=True, exist_ok=True)
    pathlib.Path(os.path.join(output, "motion"         )).mkdir(parents=True, exist_ok=True)
    pathlib.Path(os.path.join(output, "spat_norm"      )).mkdir(parents=True, exist_ok=True)
    pathlib.Path(os.path.join(output, "quality_control")).mkdir(parents=True, exist_ok=True)
    pathlib.Path(os.path.join(output, "anat", "segment")).mkdir(parents=True, exist_ok=True)

    return