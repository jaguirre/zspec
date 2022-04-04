;==================================================================
;  
; NAME		:  makesave_loadcrv_20031208
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating G0, Beta STEP 3
;==================================================================

  path = '/data1/SPIRE_PFM_SSW/20031208/'

  infiles = path+['200312081231_0_time_lc.fits']

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_20031208.sav'

