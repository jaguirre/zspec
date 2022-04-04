;==================================================================
;  
; NAME		:  makesave_loadcrv_20040601
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2004/06/01    :  B. Schulz
; 
; NOTE		:  This is calculating G0, Beta STEP 3
;==================================================================

  path = '/data1/SPIRE_PFM_PLW/20040601/'

  infiles = path+['200406011301_0_time_lc.fits']
;  ,'200406011507_0_time_lc.fits']

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_20040601.sav'

