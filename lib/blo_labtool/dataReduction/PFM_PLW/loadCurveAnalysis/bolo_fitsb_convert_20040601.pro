;=====================================================================
; NAME		: bolo_fitsb_convert_20040601 
;   
; DESCRIPTION	:  Make fits file
; 
; 2004/06/07    : B. Schulz
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================
   
   path='/data1/SPIRE_PFM_PLW/20040601/'
   infiles = findfile(path+'*.bin')
   
   ix = where(strpos(infiles, '*1301_0_time') LT 0 AND $
  	      strpos(infiles, '*1507_0_time') LT 0) 
;   	      strpos(infiles, '*_11_time') LT 0)
;    	      strpos(infiles, '*_12_time') LT 0)
;    	      strpos(infiles, '*_13_time') LT 0)
;   	      strpos(infiles, '*_14_time') LT 0)
;   	      strpos(infiles, '*_16_time') LT 0)
;   	      strpos(infiles, '*_17_time') LT 0)
;   	      strpos(infiles, '*_18_time') LT 0)
 
   bodac_fitsb_convert, infiles[ix]


