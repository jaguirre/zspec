; Decodes PLOG's 10-ms number and returns in turns (1 = 24 hours).
function decode_10ms, ix

return, double(ix) / 8640000.0d

end
