function rarity_code(x)
    x == "COMMON" && return 1
    x == "RARE" && return 2
    x == "EPIC" && return 3
    x == "LEGENDARY" && return 4
    x == "FREE" && return 0
    error("Unkown rarity $x")
end

const card_db = eval(Meta.parse(read(joinpath(@__DIR__,"..", "data", "card_db.txt"), String)))