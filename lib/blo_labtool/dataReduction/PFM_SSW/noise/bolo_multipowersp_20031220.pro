;=========================================================
; NAME		:  bolo_multipowersp_20031220
;   
; DESCRIPTION	:  Make power spectrum
; 
; 2003/12/22    : L. Zhang
; 
; NOTE		: This is data reduction STEP 2

;=========================================================
inpath='/data1/SPIRE_PFM_SSW/20031220/'
outfile = inpath+'20031220_coadd.fits'

flist = findfile(inpath+'*_time.fits')

blo_multipowersp, flist, outfile, /deglitch
