;=========================================================
; NAME		:  bolo_multipowersp_200312110936
;   
; DESCRIPTION	:  Make power spectrum
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 2

;=========================================================
inpath='/data1/SPIRE_PFM_SSW/20031211/'
outfile = inpath+'200312110936_coadd.fits'

flist = findfile(inpath+'*200312110936*_time.fits')
blo_multipowersp, flist, outfile, /deglitch
