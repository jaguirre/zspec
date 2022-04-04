;=========================================================
; NAME		:  bolo_sig2power_20040926_20mv
;
; DESCRIPTION	: make FFT power spectrum
; 
; 2004/09/30    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 2
;=========================================================


   path = '/data1/SPIRE_PFM_PMW2/20040926/20mV/'
   flist = findfile(path+'*time.fits')
   blo_sig2power, flist,  /deglitch
