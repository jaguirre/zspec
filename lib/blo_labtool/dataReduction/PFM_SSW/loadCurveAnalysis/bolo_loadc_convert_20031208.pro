;==================================================================
; NAME          :  bolo_loadc_convert_20031208
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 2
;
;==================================================================
   
   path='/data1/SPIRE_PFM_SSW/20031208/'
   infiles = findfile(path+'*.fits')

   bodac_loadc_convert, infiles
