;=====================================================================   
; NAME		: bolo_fitsb_convert_20040505_35mv 
;   
; DESCRIPTION	: convert bin files to FITS files
; 
; 2004/06/03    : B. Schulz
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_PLW/20040505/35mV/'
   infiles = findfile(path+'*.bin')

   bodac_fitsb_convert, infiles
