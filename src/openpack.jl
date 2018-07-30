function open_pack!(
    pack_contents::Vector{Tuple{Int64,Int64}},
    pack_table,
    collection::Collection,
    decklist::DecklistArray,
    parameters::HearthstoneSimParameters,
    account_state::AccountState,
    sim_state::SimState,
    output::SimOutput
    )

    set = sim_state.set

    keep_going = true
    while keep_going
        StatsBase.sample!(pack_table[set][1], pack_table[set][2], pack_contents)

        if pack_okay(pack_contents, collection, account_state.pitytimer, set, pack_table)
            keep_going = false
        end
    end

    process_pack!(pack_contents, collection, decklist, account_state, set, parameters,sim_state, output)

    for r in 3:4
        if has_rarity(pack_contents, r)
            account_state.pitytimer[set][r] = 0
        else
            account_state.pitytimer[set][r] += 1
        end
    end
end


function process_pack!(pack_contents, collection, decklist, account_state, set, parameters, sim_state, output)
    for (r,c) in pack_contents
        collection_amount = collection[r][set][c] + 1
        necessary_amount = 0
        for deck in decklist[r][set]
            for (deck_card, deck_amt) in deck
                if (c == deck_card) && (deck_amt > necessary_amount)
                    necessary_amount = deck_amt
                end
            end
        end

        isgolden = rand() < parameters.golden_probs[r]

        if collection_amount > necessary_amount
            if isgolden
                account_state.dust += dust_golden[r]
            else
                account_state.dust += dust_regular[r]
            end
        else
            collection[r][set][c] += 1
            output.cards_from_packs[set][sim_state.rep, r] += 1
        end
        output.pack_card_rarity[sim_state.rep, r] += 1
    end
end

function pack_okay(pack_contents, collection, pity_timer, set, pack_table)
    ## at least one rare:
    has_minrarity(pack_contents, 2) || return false
    enforce_pitytimer!(pack_contents, pity_timer, set, pack_table)
    has_no_duplicate_leggos(pack_contents, collection, set) || return false
    has_no_playset_overflow(pack_contents) || return false

    return true

end


function has_minrarity(pack_contents, rarity)
    for (r,c) in pack_contents
        if r >= rarity
            return true
        end
    end
    return false
end


function has_rarity(pack_contents, rarity)
    for (r,c) in pack_contents
        if r == rarity
            return true
        end
    end
    return false
end

function has_no_pitytimer_violation(pack_contents, pity_timer, set)
    if pity_timer[set][4] >= 40 && !has_rarity(pack_contents, 4)
        return false
    end

    if pity_timer[set][3] >= 10 && !has_rarity(pack_contents, 3)
        return false
    end

    return true

end

function enforce_pitytimer!(pack_contents, pity_timer, set, pack_table)
    if pity_timer[set][4] >= 40 && !has_rarity(pack_contents, 4)
        for i in eachindex(pack_contents)
            r,c = pack_contents[i]
            if r >= 2
                pack_contents[i] = StatsBase.sample( filter(x -> x[1] == 4, pack_table[set][1]) )
                return nothing
            end
        end
    elseif pity_timer[set][3] >= 10 && !has_rarity(pack_contents,3)
        for i in eachindex(pack_contents)
            r,c = pack_contents[i]
            if r >= 2
                pack_contents[i] = StatsBase.sample( filter(x -> x[1] == 3, pack_table[set][1]) )
                return nothing
            end
        end
    end
end

function has_no_playset_overflow(pack_contents)
    for i in eachindex(pack_contents)
        count = 1
        for j in (i+1):length(pack_contents)
            if pack_contents[i] == pack_contents[j]
                count += 1
            end
        end
        if count > 2 || (count > 1 && pack_contents[i] == 4)
            return false
        end
    end

    return true
end

function has_no_duplicate_leggos(pack_contents, collection, set)
    all( collection[4][set] .>= 1 ) && return true

    for (r,c) in pack_contents
        if r == 4
            if collection[4][set][c] >= 1
                return false
            end
        end
    end
    return true
end
