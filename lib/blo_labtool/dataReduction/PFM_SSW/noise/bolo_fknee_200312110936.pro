;==================================================================
; NAME		:  bolo_fknee_200312110936
;   
; DESCRIPTION	:  Calculate 1/fknee frequency
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is 1/f noise calculation STEP 3 (last step)
  
;==================================================================

    path='/data1/SPIRE_PFM_SSW/20031211/'
    infile=path+'200312110936_coadd.fits'
     
    blo_fknee, infile=infile, /goodpix,interval=[0.5, 20.], /plot
;==================================================================

