function findunique(collection, item)
    for (i,x) in pairs(IndexLinear(), collection)
        if x == item
            return i
        end
    end
    error("$item not found")
end

function generate_collection_table(sets, rarity_by_set, rarity)
    Dict(map(i -> (i, zeros(Int, rarity_by_set[i][rarity])), sets))
end

function generate_collection_table(sets, rarity_by_set)
    (generate_collection_table(sets, rarity_by_set, 1),
    generate_collection_table(sets, rarity_by_set, 2),
    generate_collection_table(sets, rarity_by_set, 3),
    generate_collection_table(sets, rarity_by_set, 4))
end

function copy_to_dict(keys, x)

    Dict(map(i -> (i, deepcopy(x)), keys))

end


function make_counter(sets, dims, T = Int)
    copy_to_dict(sets, zeros(T, dims))
end
