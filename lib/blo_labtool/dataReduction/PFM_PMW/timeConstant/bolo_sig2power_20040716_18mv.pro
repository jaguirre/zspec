;=========================================================
; NAME		:  bolo_sig2power_20040716_18mv
;
; DESCRIPTION	: make FFT power spectrum
; 
; 2004/08/04    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 2
;=========================================================


   path = '/data1/SPIRE_PFM_PMW/20040716/18mV/'
   flist = findfile(path+'*time.fits')
   blo_sig2power, flist,  /deglitch
