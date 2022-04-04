;==================================================================
;  
; NAME		:  makesave_20031208
;   
; DESCRIPTION	:  make x structure and save to a .sav file
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating Rstar, Tstar STEP 3

;==================================================================



   path = '/data1/SPIRE_PFM_SSW/20031208/'

   infiles = findfile(path+'*0_time_lc.fits')

   ix = where(strpos(infiles, '1949_0_time') LT 0 AND $
   	     strpos(infiles, '1017_0_time') LT 0 AND $
   	      strpos(infiles, '1034_0_time') LT 0)


   x = bolodark_read_loadcrv(infiles[ix])

   save, x, filename = path+'20031208.sav'

