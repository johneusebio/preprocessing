def parse_input(text, keywords, split="=", first="[", last="]"):
    key, val = parse_line(text, keywords, split)
    val = strip_chars(val, first, last)
    return(key, val)