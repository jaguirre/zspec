;=====================================================================   
; NAME		: bolo_fitsb_convert_20031007_25mv_300hz
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================   
   path = '/data1/SPIRE_PFM_SLW/20031007/25mV_300Hz_4096pts/'

   infiles = findfile(path+'*.bin')

   bodac_fitsb_convert, infiles
