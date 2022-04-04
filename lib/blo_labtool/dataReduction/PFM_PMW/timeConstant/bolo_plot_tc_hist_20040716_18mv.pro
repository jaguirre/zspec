;=========================================================
; NAME		:  bolo_plot_tc_hist_20040716_18mv
;   
; DESCRIPTION	:  Plot histogram of time constants
; 
; 2004/08/04    : B. Schulz
;
; NOTE		: This is time constant data reduction 
;		  STEP 6
;=========================================================

pro bolo_plot_tc_hist_20040716_18mv

path = '/data1/SPIRE_PFM_PMW/20040716/18mV/'


readfmt, path+'timeconst_20040716_18mV.txt', 'a12,f10,f10', pixel, tau, stau, skip=4
tau = tau*1000. ;msec

psinit
plothist, tau, charsize=1.2, xtitle='time constant [msec]', $
title='SPIRE PFM Time Constants (18mV, '+string(n_elements(tau), format='(I2)') +' Det.)', $
yrange=[0,50], ytitle='number', bin=1, xthick=4, ythick=4, thick=3, ystyle=3


psterm, file=path+'bolo_plot_tc_hist_20040716_18mV.ps'

end
