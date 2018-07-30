function spend_dust!(collection, subtarget, account_state, sim_state)
    set = subtarget.set
    for r in 1:4
        for (card, amt) in subtarget[r]
            while collection[r][set][card] < amt
                account_state.dust -= craft_regular[r]
                collection[r][set][card] += 1
            end
        end
    end
end
