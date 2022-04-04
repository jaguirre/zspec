; Decodes PLOG's 100-mas number and returns in turns (1 = 360 degrees).
function decode_100mas, ix

return, double(ix) / 12960000.0d

end

; Decodes PLOG's 10-ms number and returns in turns (1 = 24 hours).
function decode_10ms, ix

return, double(ix) / 8640000.0d

end
