;=========================================================
; NAME		:  bolo_plot_tc_hist_20040926_10mv
;   
; DESCRIPTION	:  Plot histogram of time constants
; 
; 2004/09/30    : B. Schulz
;
; NOTE		: This is time constant data reduction 
;		  STEP 6
;=========================================================

pro bolo_plot_tc_hist_20040926_10mv

path = '/data1/SPIRE_PFM_PMW2/20040926/10mV/'


readfmt, path+'timeconst_20040926_10mV.txt', 'a12,f10,f10', pixel, tau, stau, skip=4
tau = tau*1000. ;msec

psinit
plothist, tau, charsize=1.2, xtitle='time constant [msec]', $
title='SPIRE PFM Time Constants (10mV, '+string(n_elements(tau), format='(I2)') +' Det.)', $
yrange=[0,50], ytitle='number', bin=1.0, xthick=4, ythick=4, thick=3

psterm, file=path+'bolo_plot_tc_hist_20040926_10mV.ps'

end
