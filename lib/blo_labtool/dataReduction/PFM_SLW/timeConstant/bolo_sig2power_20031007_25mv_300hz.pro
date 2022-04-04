;=========================================================
; NAME		:  bolo_sig2power_20031007_25mv_300hz
;
; DESCRIPTION	:  make FFT power spectrum
; 
; 2003/12/16    : L. Zhang
;
; NOTE		: This is data reduction STEP 2
;=========================================================


   path = '/data1/SPIRE_PFM_SLW/20031007/25mV_300Hz_4096pts/'
   flist = findfile(path+'*time.fits')
   blo_sig2power, flist,  /deglitch
