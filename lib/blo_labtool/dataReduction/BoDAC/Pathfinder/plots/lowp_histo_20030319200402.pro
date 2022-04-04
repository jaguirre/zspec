pro lowp_histo_20030319200402

path = '/data1/BoDAC/3_Pathfinder/20030402/'
fname = 'RstarTstar20030319200402.txt'

bolodark_restore_rtstar, chan, rstar, tstar, path=path, filename=fname

; read exclude pixels
goodpix = blo_getgoodpix()

nc = n_elements(chan)


; filter out those
flg = intarr(nc)
for i=0, nc-1 do begin
  ix = where(chan[i] EQ goodpix, cnt)
  if cnt GT 0 then flg[i] = 1  
endfor

ix = where(flg GT 0,cnt)	;pointers to good pixels


!p.multi=[0,1,2]
psinit, /full, /letter

plothist, rstar[ix], xhist, yhist, bin=2000, charsize=1.6, $
ytitle = '# R_star', xtitle='R_star [Ohm]', xthick=2, ythick=2, $
title = 'R_star for T_c below 0.4 K'

plothist, tstar[ix], xhist, yhist, bin=0.2, charsize=1.6, $
ytitle = '# T_star', xtitle='T_star [Ohm]', xthick=2, ythick=2, $
title = 'T_star for T_c below 0.4 K'
psterm, file=path+'lowp_histo_20030319200402.ps'
!p.multi=0


end
