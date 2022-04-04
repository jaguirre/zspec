; Plot histogram of time constants

pro pl_tc_hist20030715

path = '/data1/SPIRE_CQM/20030715/'


readfmt, path+'timeconst.txt', 'a12,f10,f10', pixel, tau, stau, skip=4
tau = tau*1000. ;msec

psinit
plothist, tau, charsize=1.8, xtitle='time constant [msec]', $
title='SPIRE CQM Time Constants ('+string(n_elements(tau), format='(I2)') +' Det.)', $
yrange=[0,13], ytitle='number', bin=3, xthick=4, ythick=4, thick=3

psterm, file=path+'pl_tc_hist20030715.ps'

end
