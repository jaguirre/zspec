;=========================================================
; NAME		:  bolo_sig2power_20031007_25mv
;
; DESCRIPTION	:  make FFT power spectrum
; 
; 2003/12/16    :  L. Zhang
;
; NOTE		:  This is data reduction STEP 2
;=========================================================


   path = '/data1/SPIRE_PFM_SLW/20031007/25mV/'
   flist = findfile(path+'*time.fits')
   blo_sig2power, flist,  /deglitch
