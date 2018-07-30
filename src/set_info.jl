const sets = Symbol.(["UNGORO", "ICECROWN", "LOOTAPALOOZA", "GILNEAS", "EXPERT1" ])

function make_rarity_db_set(set, rarity)
    set_db = filter( p -> p.second[1] == set, card_db)
    this_rarity = filter( p -> p.second[3] == rarity, set_db)
    collection_numbers = map( x -> x[2], values(this_rarity))
    sort(collection_numbers)
end

function make_rarity_db()
    Dict([
        set => ([make_rarity_db_set(set, i) for i in 1:4]...,) for set in sets
    ])
end

const rarity_db = make_rarity_db()
const ncard_db = Dict([set => map(length, rarity_db[set]) for set in keys(rarity_db)])

