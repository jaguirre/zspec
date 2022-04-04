;=========================================================
;  
; NAME		:  blo_multipowersp_20031009
;   
; DESCRIPTION	:  Make power spectrum
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is data reduction STEP 2

;=========================================================
 inpath='/data1/SPIRE_PFM_SLW/20031009/'
 outfile = inpath+'200310091722_coadd.fits'

 flist = findfile(inpath+'*200310091722*_time.fits')
 blo_multipowersp, flist, outfile, /deglitch
