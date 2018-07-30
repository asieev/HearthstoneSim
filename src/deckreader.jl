function deckreader(file)
    lines = readlines(file)
    filter!(x -> occursin(r"^# \d+x", x), lines)
    matches = match.(Ref(r"^# (\d+)x"), lines)
    counts = map(x -> parse(Int, x.captures[1]), matches)
    matches = match.(Ref(r"\(\d+\) (.+)$"), lines)
    names = String.(strip.(map(x -> convert(String, x.captures[1]), matches)))
    collect(zip(names, counts))
end
