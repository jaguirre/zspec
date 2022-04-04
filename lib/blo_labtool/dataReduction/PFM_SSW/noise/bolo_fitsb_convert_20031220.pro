;=====================================================================
; NAME		: bolo_fitsb_convert_20031220
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/22   : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================
   
   path='/data1/SPIRE_PFM_SSW/20031220/'
   infiles = findfile(path+'*.bin')
   
   ix = where(strpos(infiles, '_0_time.bin') LT 0 AND $
             strpos(infiles, '_1_time.bin') LT 0 AND $
             strpos(infiles, '_2_time.bin') LT 0 AND $
             strpos(infiles, '_3_time.bin') LT 0 AND $
             strpos(infiles, '_4_time.bin') LT 0 AND $
             strpos(infiles, '_5_time.bin') LT 0 AND $
             strpos(infiles, '_6_time.bin') LT 0 AND $
             strpos(infiles, '_7_time.bin') LT 0 AND $
             strpos(infiles, '_8_time.bin') LT 0 AND $
             strpos(infiles, '_9_time.bin') LT 0 AND $
  	     strpos(infiles, '_10_time.bin') LT 0 AND $
   	     strpos(infiles, '_11_time.bin') LT 0 AND $
    	     strpos(infiles, '_12_time.bin') LT 0 AND $
    	     strpos(infiles, '_13_time.bin') LT 0 AND $
   	     strpos(infiles, '_14_time.bin') LT 0 AND $
   	     strpos(infiles, '_15_time.bin') LT 0 AND $
   	     strpos(infiles, '_16_time.bin') LT 0 AND $
   	     strpos(infiles, '_17_time.bin') LT 0 AND $
   	     strpos(infiles, '_18_time.bin') LT 0  )

   bodac_fitsb_convert, infiles[ix]
