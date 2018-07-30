const dust_regular = (5, 20, 100, 400)
const dust_golden = (50, 100, 400, 1600)

const craft_regular = (40, 100, 400, 1600)

function hssim(
        nreps::Int,
        decklist::DecklistArray,
        sets::Vector{Symbol},
        parameters::HearthstoneSimParameters = HearthstoneSimParameters()
    )
    
    sets_in_decklist = mapreduce(i -> collect(keys(decklist[i])), union, 1:4)

    @assert issubset(sets, sets_in_decklist)

    collection = Collection(sets, parameters.rarity_by_set)
    fresh_collection = deepcopy(collection)

    account_state::AccountState = AccountState()
    account_state.bonus_packs[:EXPERT1] = 7
    for s in parameters.sets_with_bonus
        account_state.bonus_packs[s] += 3
    end
    account_state.dust += parameters.bonus_dust
    if parameters.welcome_bundle
        account_state.dust += 400
        account_state.bonus_packs[:EXPERT1] += 10
    end
    fresh_account = deepcopy(account_state)

    ndeck = length(decklist)

    output = SimOutput(sets, nreps, ndeck)

    pack_table = Dict(
        map(x -> (x, packtablegen(ncard_db[x], parameters.rarity_probs)), sets)
    )

    pack_contents = map(i -> (0,0), 1:5)

    deckiter = collect(1:length(decklist))
    setiter = deepcopy(sets)

    for rep = 1:nreps

        if parameters.startfresh
            account_state = deepcopy(fresh_account)
            collection = deepcopy(fresh_collection)
        end

        for deckidx in deckiter
            for set in setiter
                sim_state::SimState = SimState(rep = rep, deck = deckidx, set = set, npacks = 0)

                subtarget = SingleSetDeckArray(decklist, set, deckidx)

                while missing_cards(collection, subtarget)

                    if account_state.dust >= remaining_dust(collection, subtarget)
                        spend_dust!(collection, subtarget, account_state, sim_state)
                        break
                    end

                    if account_state.bonus_packs[set] == 0
                        sim_state.npacks += 1
                    else
                        account_state.bonus_packs[set] -= 1
                    end

                    open_pack!(pack_contents,pack_table, collection, decklist, parameters,
                    account_state, sim_state, output)


                end

                output.total_packs_for_deck[set][deckidx, rep] = sim_state.npacks
                output.total_packs[set][rep] += sim_state.npacks

            end
        end


    end


    output
end
