;=====================================================================   
; NAME		: bolo_fitsb_convert_20040926_30mv 
;   
; DESCRIPTION	: convert bin files to FITS files
; 
; 2004/09/30    : B. Schulz
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   
   path='/data1/SPIRE_PFM_PMW2/20040926/30mV/'
   infiles = findfile(path+'*.bin')
   
   bodac_fitsb_convert, infiles[3:*]
