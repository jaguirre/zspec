erase

;whflags = lindgen(32)
whflags = [8,9,10,11,12,13,14,15];,21,22]
;whflags = [0,1,2,3,4,5,6,7,21,22]

multiplot,[1,n_e(whflags)]

for i=0,n_e(whflags)-1 do begin

plot,data.ticks/60.,data.flags[whflags[i],*],/xst,/yst,yr=[-0.2,1.2],yticks=0
oplot,data.ticks/60.,data.flags[whflags[i],*],col=2

multiplot

;blah = ''
;read,blah

endfor

end
