def interpret_input(filepath):
    input = open(filepath, "r")
    lines = input.readlines()

    keywords = ["FUNC", "ANAT", "OUTPUT"]
    input_df = pd.DataFrame(index=range(len(lines)), columns=keywords)

    for line, ind in zip(lines, range(len(lines))):
        line=line.strip()
        input_dict=interpret_input_line(line, keywords)

        input_df.loc[ind,"FUNC"  ] = input_dict["FUNC"]
        input_df.loc[ind,"ANAT"  ] = input_dict["ANAT"]
        input_df.loc[ind,"OUTPUT"] = input_dict["OUTPUT"]

    return(input_df)