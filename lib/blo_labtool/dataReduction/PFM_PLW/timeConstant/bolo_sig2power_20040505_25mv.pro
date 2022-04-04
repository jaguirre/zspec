;=========================================================
; NAME		:  bolo_sig2power_20040505_25mv
;
; DESCRIPTION	: make FFT power spectrum
; 
; 2004/06/03    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 2
;=========================================================


   path = '/data1/SPIRE_PFM_PLW/20040505/25mV/'
   flist = findfile(path+'*time.fits')
   blo_sig2power, flist,  /deglitch
