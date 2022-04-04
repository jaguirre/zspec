;=====================================================================   
; NAME		: bolo_fitsb_convert_20040716_18mv 
;   
; DESCRIPTION	: convert bin files to FITS files
; 
; 2004/08/04    : B. Schulz
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_PMW/20040716/18mV/'
   infiles = findfile(path+'*.bin')

   bodac_fitsb_convert, infiles
