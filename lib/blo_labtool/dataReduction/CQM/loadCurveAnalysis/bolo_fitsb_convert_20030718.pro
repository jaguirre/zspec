;=====================================================================
; NAME		: bolo_fitsb_convert_20030718 
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;
; 2004/02/04    modified for CQM   B.Schulz
;=====================================================================
   
   path='/data1/SPIRE_CQM/20030718/'
   infiles = findfile(path+'*.bin')
    
   bodac_fitsb_convert, infiles
