;=====================================================================
; NAME		: bolo_fitsb_convert_20031208 
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================
   
   path='/data1/SPIRE_PFM_SSW/20031208/'
   infiles = findfile(path+'*.bin')
   
   ix = where(strpos(infiles, '*_0_time') LT 0 AND $
   	     strpos(infiles, '*_10_time') LT 0 AND $
   	      strpos(infiles, '*_11_time') LT 0)
    	      strpos(infiles, '*_12_time') LT 0)
    	      strpos(infiles, '*_13_time') LT 0)
   	      strpos(infiles, '*_14_time') LT 0)
   	      strpos(infiles, '*_16_time') LT 0)
   	      strpos(infiles, '*_17_time') LT 0)
   	      strpos(infiles, '*_18_time') LT 0)
 
   bodac_fitsb_convert, infiles[ix]
