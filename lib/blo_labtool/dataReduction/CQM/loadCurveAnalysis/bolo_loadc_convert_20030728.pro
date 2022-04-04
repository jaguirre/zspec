;==================================================================
; NAME          :  bolo_loadc_convert_20030728
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 2
;
; 2004/04/26    modified for CQM   B.Schulz
;==================================================================
   
   path='/data1/SPIRE_CQM/20030728/'
   infiles = findfile(path+'*time.fits')

   bodac_loadc_convert, infiles
