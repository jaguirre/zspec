function bin2dec, bin

; Takes a binary representation bin, stored as an array of nbits bits
; and returns the decimal equivalent.  LSB is assumed to be rightmost.

nbits = long(n_e(bin))

dec = 0
for i=nbits-1,0,-1 do begin

    dec = dec + bin[nbits-1-i]*2^i

endfor

return, dec

end
