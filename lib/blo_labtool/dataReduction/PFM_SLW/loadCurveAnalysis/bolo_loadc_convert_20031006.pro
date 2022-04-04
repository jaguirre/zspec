;==================================================================
; NAME          :  bolo_loadc_convert_20031006
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 2
;
;==================================================================
   
   path='/data1/SPIRE_PFM_SLW/20031006/'
   infiles = findfile(path+'*time.fits')

   bodac_loadc_convert, infiles
