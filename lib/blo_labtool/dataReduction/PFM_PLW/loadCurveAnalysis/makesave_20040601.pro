;==================================================================
;  
; NAME		:  makesave_20040601
;   
; DESCRIPTION	:  make x structure and save to a .sav file
; 
; 2004/06/08    :  B. Schulz
; 
; NOTE		:  This is calculating Rstar, Tstar STEP 3

;==================================================================



   path = '/data1/SPIRE_PFM_PLW/20040601/'

   infiles = findfile(path+'*0_time_lc.fits')

 ;  ix = where(strpos(infiles, '1949_0_time') LT 0 AND $
 ;  	     strpos(infiles, '1017_0_time') LT 0 AND $
 ;  	      strpos(infiles, '1034_0_time') LT 0)


;   x = bolodark_read_loadcrv(infiles[ix])
   x = bolodark_read_loadcrv(infiles)

   save, x, filename = path+'20040601.sav'

