; Create a matrix of transitions based on the Bohr model

nl = 200
n = dindgen(nl)+1

; Energy levels of the states
e = -13.6/n^2
; Convert eV to J
e *= 1.602d-19

h = 6.626d-34
c = 3.0d8

de = dblarr(nl,nl)

; Calculate transition energy from upper state to lower state
for l = 0,nl-2 do begin

    print,l+1
    for u=l+1,nl-1 do begin
        de[u,l] = e[u]-e[l]
    endfor

endfor

lambda = h*c/de
nu = de / h 

wh = where(nu/1.d9 gt 200 and nu/1.d9 lt 300)

plot,[190,310],[0,1],/xst,/yst,/nodata

for i=0,n_e(wh)-1 do vline,nu[wh[i]]/1.d9

end
