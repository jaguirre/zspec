function dectobin32, idec

; Converts unsigned longs in dec to 32 bit representation
dec = ulong(idec)
nel = n_e(dec)

bin = intarr(nel,32)

for i = 0,31 do begin
    bin[*,i] = uint(dec/(2.d^(31.d - i)))
    dec = dec - bin[*,i]*2.d^(31.d - i)
endfor

if (nel eq 1) then bin = reform(bin) else bin = transpose(bin)

return, bin

end
