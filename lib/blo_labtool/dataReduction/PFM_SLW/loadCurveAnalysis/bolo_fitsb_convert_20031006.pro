;+
;=====================================================================
; NAME		: bolo_fitsb_convert_20031006
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================
;-   
   path='/data1/SPIRE_PFM_SLW/20031006/'
   infiles = findfile(path+'*.bin')

   bodac_fitsb_convert, infiles
