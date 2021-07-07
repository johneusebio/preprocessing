def strip_chars(text, first, last):
    text = "{}".format(text[1:] if text.startswith(first) else text)
    text = "{}".format(text[:-1] if text.endswith(last) else text)
    return(text)