;=====================================================================
; NAME		: bolo_fitsb_convert_200307221320
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;
; 2004/02/04    modified for CQM           B.Schulz
; 2004/03/11    modified for 200307221320  B.Schulz
;=====================================================================
   
   path='/data1/SPIRE_CQM/20030722b/'
   infiles = findfile(path+'*.bin')
    
   bodac_fitsb_convert, infiles
