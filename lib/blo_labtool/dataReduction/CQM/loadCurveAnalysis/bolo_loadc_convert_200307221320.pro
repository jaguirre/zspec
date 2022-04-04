;==================================================================
; NAME          :  bolo_loadc_convert_200307221320
;   
; DESCRIPTION	:  Convert the fits file to load curve files
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 2
;
; 2004/02/04    modified for CQM           B.Schulz
; 2004/03/11    modified for 200307221320  B.Schulz
;==================================================================
   
   path='/data1/SPIRE_CQM/20030722b/'
   infiles = findfile(path+'*time.fits')

   bodac_loadc_convert, infiles
