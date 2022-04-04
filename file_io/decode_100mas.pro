; Decodes PLOG's 100-mas number and returns in turns (1 = 360 degrees).
function decode_100mas, ix

return, double(ix) / 12960000.0d

end
