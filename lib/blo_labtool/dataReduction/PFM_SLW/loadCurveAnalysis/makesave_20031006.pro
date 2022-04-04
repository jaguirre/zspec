;==================================================================
;  
; NAME		:  makesave_20031006
;
; DESCRIPTION	:  make x structure and save to a .sav file
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating Rstar, Tstar STEP 3
;   
;==================================================================
path = '/data1/SPIRE_PFM_SLW/20031006/'

infiles = findfile(path+'*_time_lc.fits')
ix = where(strpos(infiles, '1203_0_time_lc') lt 0 and $
           strpos(infiles, '1217_0_time_lc') lt 0 and $
           strpos(infiles, '1223_0_time_lc') lt 0 and $
           strpos(infiles, '1340_0_time_lc') lt 0 and $
           strpos(infiles, '1406_0_time_lc') lt 0 and $
           strpos(infiles, '1430_0_time_lc') lt 0 and $
           strpos(infiles, '1447_0_time_lc') lt 0 )


x = bolodark_read_loadcrv(infiles[ix])

save, x, filename = path+'20031006.sav'

