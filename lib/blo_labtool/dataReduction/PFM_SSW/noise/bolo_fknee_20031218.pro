;==================================================================
; NAME		:  bolo_fknee_20031218
;   
; DESCRIPTION	:  Calculate 1/fknee frequency
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is 1/f noise calculation STEP 3 (last step)
  
;==================================================================

    path='/data1/SPIRE_PFM_SSW/20031218/'
    infile=path+'20031218_coadd.fits'
     
    blo_fknee, infile=infile, /goodpix,interval=[0.5, 20.], /plot
;==================================================================

