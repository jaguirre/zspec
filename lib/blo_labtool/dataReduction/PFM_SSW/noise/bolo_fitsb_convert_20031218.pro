;=====================================================================
; NAME		: bolo_fitsb_convert_20031218
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/18    : L. Zhang
; 
; NOTE		: This is data reduction STEP 1
;=====================================================================
   
   path='/data1/SPIRE_PFM_SSW/20031218/'
   infiles = findfile(path+'*.bin')

   ;excluding the files with extension _30 or higher
   ix = where(strpos(infiles,  '30_time.bin')  LT 0  AND  $
               strpos(infiles, '31_time.bin')  LT 0  AND  $
               strpos(infiles, '32_time.bin')  LT 0  AND  $
               strpos(infiles, '33_time.bin')  LT 0  AND  $
               strpos(infiles, '34_time.bin')  LT 0  AND  $
               strpos(infiles, '35_time.bin')  LT 0   )
	       
   bodac_fitsb_convert, infiles[ix]
