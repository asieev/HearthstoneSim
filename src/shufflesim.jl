
function shufflesim(decks::DecklistArray; shuffledecks = shuffle, parameters = HearthstoneSimParameters(),
    sets = sets, reps, batchsize)
   total_ouput = SimOutput(sets,  reps * batchsize,  length(decks))


   index = 1
   for i = 1:reps
       simres = hssim(batchsize, shuffledecks(decks), sets,deepcopy(parameters))
       index = copy_into_output!(total_ouput, simres; startindex = index)
   end

   total_ouput
end

function shuffle(x::DecklistArray)
    ans = deepcopy(x)
    sets = keys(x.commons)
    n = length(x.commons[first(sets)])
    p = randperm(n)
    for r in 1:4
        for set in sets
            permute!(ans[r][set],p)
        end
    end
    ans
end