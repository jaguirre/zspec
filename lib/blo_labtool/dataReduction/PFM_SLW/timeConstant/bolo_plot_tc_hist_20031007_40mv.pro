;=========================================================
; NAME		:  bolo_plot_tc_hist_20031007_40mv
;   
; DESCRIPTION	:  Plot histogram of time constants
; 
; 2003/10/14    : L. Zhang
;
; NOTE		: This is time constant data reduction 
;		  STEP 6
;=========================================================

pro bolo_plot_tc_hist_20031007_40mv

path = '/data1/SPIRE_PFM_SLW/20031007/40mV/'


readfmt, path+'bolo_timeconst_20031007_40mV.txt', 'a12,f10,f10', pixel, tau, stau, skip=4
tau = tau*1000. ;msec

psinit
plothist, tau, charsize=1.2, xtitle='time constant [msec]', $
title='SPIRE PFM Time Constants (40mV, 150Hz, '+string(n_elements(tau), format='(I2)') +' Det.)', $
yrange=[0,13], ytitle='number', bin=3, xthick=4, ythick=4, thick=3

psterm, file=path+'bolo_plot_tc_hist_20031007_40mV.ps'

end
