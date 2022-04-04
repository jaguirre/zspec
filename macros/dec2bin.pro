function dec2bin, idec, nbits

; Converts an unsigned long decimal number dec to an array of nbits
; containing the binary representation.

if (idec ge 2.d^(double(nbits))) then begin
    message,/info,$
      string('Input decimal number cannot be represented in ',$
             strcompress(nbits,/rem),' bits.', $
             format = '(A,A,A)')
    message,/info,$
      string('Returning largest possible ', $
             strcompress(nbits,/rem),' bit number.',$
             format='(A,A,A)')
    return,replicate(1,nbits)
endif

dec = ulong(idec)
nel = n_e(dec)

nbits = long(nbits)
bin = intarr(nel,nbits)

for i = 0,nbits-1 do begin
    bin[*,i] = uint(dec/(2.d^(double(nbits-1) - i)))
    dec = dec - bin[*,i]*2.d^(double(nbits-1) - i)
endfor

if (nel eq 1) then bin = reform(bin) else bin = transpose(bin)

return, bin

end
