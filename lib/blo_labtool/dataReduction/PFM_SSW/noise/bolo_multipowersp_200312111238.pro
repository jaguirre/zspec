;=========================================================
; NAME		:  bolo_multipowersp_200312111238
;   
; DESCRIPTION	:  Make power spectrum
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 2
  
;=========================================================

  inpath='/data1/SPIRE_PFM_SSW/20031211/'
  outfile = inpath+'200312111238_coadd.fits'

  flist = findfile(inpath+'*200312111238*_time.fits')
  blo_multipowersp, flist, outfile, /deglitch
