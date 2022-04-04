;==================================================================
;  
; NAME		:  makesave_loadcrv_20040203
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2004/4/12     :  L. Zhang
;	           NOTE: Test the data downloading from QLA
;==================================================================

  path = '/data1/SPIRE_CQM/20040203/'

  infiles = path+'DarkLoadCurve200402032200_lc.fits'

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_20040203.sav'

