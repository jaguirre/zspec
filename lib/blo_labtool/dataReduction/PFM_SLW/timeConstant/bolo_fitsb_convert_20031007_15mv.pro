;=====================================================================   
; NAME		: bolo_fitsb_convert_20031007_15mv 
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_SLW/20031007/15mV/'
   infiles = findfile(path+'*.bin')

   bodac_fitsb_convert, infiles
