;=========================================================
; NAME		:  bolo_plot_tc_hist_20040505_15mv
;   
; DESCRIPTION	:  Plot histogram of time constants
; 
; 2004/06/03    : B. Schulz
;
; NOTE		: This is time constant data reduction 
;		  STEP 6
;=========================================================

pro bolo_plot_tc_hist_20040505_15mv

path = '/data1/SPIRE_PFM_PLW/20040505/15mV/'


readfmt, path+'timeconst_20040505_15mV.txt', 'a12,f10,f10', pixel, tau, stau, skip=4
tau = tau*1000. ;msec

psinit
plothist, tau, charsize=1.2, xtitle='time constant [msec]', $
title='SPIRE PFM Time Constants (15mV, '+string(n_elements(tau), format='(I2)') +' Det.)', $
yrange=[0,13], ytitle='number', bin=3, xthick=4, ythick=4, thick=3

psterm, file=path+'bolo_plot_tc_hist_20040505_15mV.ps'

end
