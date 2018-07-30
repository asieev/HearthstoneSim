
function missing_cards(col::Collection, subtarget::SingleSetDeckArray)
    for rarity in (4,3,2,1)
        if missing_cards(col[rarity][subtarget.set], subtarget[rarity])
            return true
        end
    end
    return false
end

function missing_cards(col::Collection, subtarget::SingleSetDeckArray, rarity::Int)
    if missing_cards(col[rarity][subtarget.set], subtarget[rarity])
        return true
    end
    return false
end

function missing_cards(A::Vector{Int}, subset::Vector{Tuple{Int,Int}})
    for i in subset
        if A[i[1]] < i[2]
            return true
        end
    end
    return false
end


function count_missing(A::Vector{Int}, subset::Vector{Tuple{Int,Int}})
    missing = 0
    for i in subset
        missing += (i[2] - A[i[1]])
    end
    missing
end

function remaining_dust(col::Collection, x::SingleSetDeckArray)
    dust = 0
    for r in 1:4
        dust += count_missing(col[r][x.set], x[r]) * craft_regular[r]
    end
    dust
end