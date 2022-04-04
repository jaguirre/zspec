function normalize_chopper, chopper

chop = chopper

chop = chop - mean(chop)

chop = chop / max(chop)

return, chop

end
