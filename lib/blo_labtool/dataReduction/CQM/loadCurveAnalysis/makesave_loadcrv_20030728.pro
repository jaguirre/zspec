;==================================================================
;  
; NAME		:  makesave_loadcrv_20030728
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  
;
; 2004/04/26    modified for CQM   B.Schulz
;==================================================================

  path = '/data1/SPIRE_CQM/20030728/'

  infiles = findfile(path+'*_time_lc.fits')

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_20030728.sav'

