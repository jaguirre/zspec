restore,'FLS3/FLS3_20100318-20100501_noflags.sav'

uber_struct = uber_psderror

nodspec = uber_struct.in1.nodspec

nnods = n_e(nodspec[0,*])

contfit = dblarr(4,nnods)
nu = freqid2freq()

goodbolos = lonarr(160)+1
goodbolos[81] = 0

whgood = where(goodbolos)


for i=0,nnods-1 do begin

    a = poly_fit(nu[whgood],reform(nodspec[whgood,i]),3)
    contfit[*,i] = a

    plot,nu,nodspec[*,i],/xst,/yst,yr=[-0.5,0.5]
    oplot,nu,poly(nu,a),col=2

;    wait,.1

    nodspec[*,i] -= poly(nu,a)

endfor

uber_struct.in1.nodspec = nodspec

spectra_ave,uber_struct

end
