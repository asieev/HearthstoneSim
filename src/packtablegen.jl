function packtablegen(lengths, rarity_pct)
    weights = rarity_pct ./ lengths
    ans = Vector{ Tuple{Int,Int} }(undef, sum(lengths) )
    wvec = zeros(Float64, sum(lengths) )
    i = 0
    for (rarity,len) in enumerate( lengths)
        for j in 1:len
            i += 1
            ans[i] = (rarity, j )
            wvec[i] = weights[rarity]
        end
    end
    ans, StatsBase.weights(wvec)
end
