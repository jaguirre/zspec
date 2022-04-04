;=========================================================
; NAME		:  bolo_multipowersp_20031218
;   
; DESCRIPTION	:  Make power spectrum
; 
; 2003/12/19    : L. Zhang
; 
; NOTE		: This is data reduction STEP 2

;=========================================================
inpath='/data1/SPIRE_PFM_SSW/20031218/'
outfile = inpath+'20031218_coadd.fits'

flist = findfile(inpath+'*_time.fits')

blo_multipowersp, flist, outfile, /deglitch
