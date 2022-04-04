;=====================================================================   
; NAME		: bolo_fitsb_convert_20040716_30mv 
;   
; DESCRIPTION	: convert bin files to FITS files
; 
; 2004/08/04    : B. Schulz
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_PMW/20040716/30mV/'
   infiles = findfile(path+'*.bin')
   
   bodac_fitsb_convert, infiles[3:*]
