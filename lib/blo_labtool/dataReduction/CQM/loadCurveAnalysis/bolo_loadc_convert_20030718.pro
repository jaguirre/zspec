;==================================================================
; NAME          :  bolo_loadc_convert_20030718
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 2
;
; 2004/02/04    modified for CQM   B.Schulz
;==================================================================
   
   path='/data1/SPIRE_CQM/20030718/'
   infiles = findfile(path+'*time.fits')

   bodac_loadc_convert, infiles
