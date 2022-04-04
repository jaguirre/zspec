;==================================================================
;  
; NAME		:  makesave_20030718
;   
; DESCRIPTION	:  make x structure and save to a .sav file
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating Rstar, Tstar STEP 3
;
; 2004/02/04    modified for CQM   B.Schulz
;==================================================================



   path = '/data1/SPIRE_CQM/20030718/'

   infiles = findfile(path+'*0_time_lc.fits')

   x = bolodark_read_loadcrv(infiles)

   save, x, filename = path+'20030718.sav'

