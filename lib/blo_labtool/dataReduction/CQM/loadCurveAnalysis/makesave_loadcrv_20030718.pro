;==================================================================
;  
; NAME		:  makesave_loadcrv_20030718
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating G0, Beta STEP 3
;
; 2004/02/04    modified for CQM   B.Schulz
;==================================================================

  path = '/data1/SPIRE_CQM/20030718/'

  infiles = path+['200307181536_0_time_lc.fits']

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_20030718.sav'

