;==================================================================
; NAME          :  bolo_loadc_convert_20040601
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2004/06/08    :  B. Schulz
; 
; NOTE		:  This is load curve data reduction STEP 2
;
;==================================================================
   
   path='/data1/SPIRE_PFM_PLW/20040601/'
   infiles = findfile(path+'*time.fits')

   bodac_loadc_convert, infiles, ubiasoffs=0.00004
