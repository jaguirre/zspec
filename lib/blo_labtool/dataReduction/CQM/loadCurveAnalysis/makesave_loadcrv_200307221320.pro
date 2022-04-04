;==================================================================
;  
; NAME		:  makesave_loadcrv_200307221320
;   
; DESCRIPTION	:  make load curve x structure
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is calculating G0, Beta STEP 3
;
; 2004/02/04    modified for CQM   B.Schulz
; 2004/03/11    modified for 200307221320  B.Schulz
;==================================================================

  path = '/data1/SPIRE_CQM/20030722b/'

  infiles = path+['200307221320_0_time_lc.fits']

  x = bolodark_read_loadcrv(infiles)

  save, x, filename = path+'loadcrv_200307221320.sav'

