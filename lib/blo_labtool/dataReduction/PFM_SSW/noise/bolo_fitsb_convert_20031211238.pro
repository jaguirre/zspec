;=====================================================================   
; NAME		: bolo_fitsb_convert_200312111238
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_SSW/20031211/'
   infiles = findfile(path+'200312111238*.bin')

   bodac_fitsb_convert, infiles
