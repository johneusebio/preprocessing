def parse_line(text, keywords, split="="):
    key, val = text.split(split)
    if key not in keywords:
        raise Exception("Input doesn't contain any of the specified key words")
    return(key, val)