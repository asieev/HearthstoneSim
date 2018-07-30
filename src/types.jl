const SetCounter = Dict{Symbol, Vector{Int}}
const SetDeckCounter = Dict{Symbol,Array{Int64,2}}
const SetRarityCounter = Dict{Symbol,Array{Int64,2}}

abstract type RarityGrouping end

function Base.:getindex(x::RarityGrouping, rarity::Int)
    rarity == 1 && return x.commons
    rarity == 2 && return x.rares
    rarity == 3 && return x.epics
    return x.legendaries
end


Base.:start(iter::RarityGrouping) = 0
function Base.:next(iter::RarityGrouping, state)
    state == 0 && return (iter.commons, 1)
    state == 1 && return (iter.rares, 2)
    state == 2 && return (iter.epics, 3)
    return (iter.legendaries, 4)
end
Base.:done(iter::RarityGrouping, state) = state > 3


struct Collection <: RarityGrouping
    commons::Dict{Symbol,Vector{Int}}
    rares::Dict{Symbol,Vector{Int}}
    epics::Dict{Symbol,Vector{Int}}
    legendaries::Dict{Symbol,Vector{Int}}
end

function Collection(sets, ncard_db)::Collection
    Collection(
        generate_collection_table(sets, ncard_db, 1),
        generate_collection_table(sets, ncard_db, 2),
        generate_collection_table(sets, ncard_db, 3),
        generate_collection_table(sets, ncard_db, 4)
    )
end


struct DecklistArray <: RarityGrouping
    commons::Dict{Symbol,Array{Array{Tuple{Int64,Int64},1},1}}
    rares::Dict{Symbol,Array{Array{Tuple{Int64,Int64},1},1}}
    epics::Dict{Symbol,Array{Array{Tuple{Int64,Int64},1},1}}
    legendaries::Dict{Symbol,Array{Array{Tuple{Int64,Int64},1},1}}
end

function Base.:length(x::DecklistArray)
    z = x.commons
    k = first(keys(z))
    length(z[k])
end


struct SingleSetDeckArray <: RarityGrouping
    set::Symbol
    commons::Vector{Tuple{Int,Int}}
    rares::Vector{Tuple{Int,Int}}
    epics::Vector{Tuple{Int,Int}}
    legendaries::Vector{Tuple{Int,Int}}
end

function SingleSetDeckArray(dla::DecklistArray, set::Symbol, deck::Int)
    ans = Vector{Vector{Tuple{Int,Int}}}(undef, 4)
    for (r,x) in enumerate(dla)
        ans[r] = x[set][deck]
    end
    SingleSetDeckArray(set, ans...)
end


function deck_to_int(deck)

    ans = map(i -> Dict(map( x -> (x, Tuple{Int,Int}[]), sets)), 1:4)
    for (name,count) in values(deck)
        set,id,rarity = card_db[name]
        if rarity > 0
            pos = findunique( rarity_db[set][rarity], id)
            push!( ans[rarity][set], (pos, count))
        end
    end
    ans
end

function DecklistArray(decks)::DecklistArray
    ans = map( i -> Dict( map( x-> (x, Vector{Vector{Tuple{Int,Int}}}()), sets)), 1:4)
    for v in values(decks)
        deckarray = deck_to_int(v)
        for i in 1:4
            for set in sets
                push!(ans[i][set], deckarray[i][set])
            end
        end
    end
    DecklistArray(
        ans[1], ans[2], ans[3], ans[4]
    )
end

@with_kw mutable struct AccountState
    dust::Int = 0
    bonus_packs::Dict{Symbol,Int} = Dict(map(x -> (x, 0), sets))
    pitytimer::Dict{Symbol,Vector{Int}} = Dict(map(x -> (x, [0,0,0,30]), sets))
end

@with_kw struct HearthstoneSimParameters
    rarity_probs::Vector{Float64} = [71.4,12.51,2.18,0.53] / 100
    golden_probs::Vector{Float64} = 1 ./ [47.9, 17.1, 18.0, 11.8]
    use_pitytimer::Bool = true
    rarity_by_set::Dict{Symbol,NTuple{4,Int}} = ncard_db
    startfresh::Bool = true
    bonus_dust::Int = 400
    sets_with_bonus::Vector{Symbol} = [:GILNEAS]
    welcome_bundle::Bool = false
end

@with_kw struct SimOutput
    total_packs::SetCounter
    total_packs_for_deck::SetDeckCounter
    cards_from_packs::SetRarityCounter
    pack_card_rarity::Array{Int,2}
end

function SimOutput(sets::Vector{Symbol}, nreps::Int, ndeck::Int)::SimOutput
    SimOutput(
        total_packs = make_counter(sets, nreps),
        total_packs_for_deck = make_counter(sets, (ndeck, nreps)),
        cards_from_packs = make_counter(sets, (nreps, 4)),
        pack_card_rarity = zeros(Int, (nreps, 4))
    )
end

function copy_into_output!(total::SimOutput, partial::SimOutput; startindex::Int, sets = sets)
    endindex = startindex + size(partial.pack_card_rarity,1) - 1
    range = startindex:endindex

    for set in sets
        total.total_packs[set][range] = partial.total_packs[set]
        total.total_packs_for_deck[set][:,range] = partial.total_packs_for_deck[set]
        total.cards_from_packs[set][range,:] = partial.cards_from_packs[set]
    end
    total.pack_card_rarity[range,:] = partial.pack_card_rarity
    endindex + 1
end


@with_kw mutable struct SimState
    rep::Int
    deck::Int
    set::Symbol
    npacks::Int
end
