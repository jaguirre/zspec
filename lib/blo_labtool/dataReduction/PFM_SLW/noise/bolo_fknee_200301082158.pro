;==================================================================
;  
; NAME		:  bolo_fknee_200310082158
;   
; DESCRIPTION	:  Calculate 1/fknee frequency
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is 1/f noise calculation STEP 3 (last step)

;==================================================================

    infile='/data1/SPIRE_PFM_SLW/20031008/200310082158_coadd.fits'
     
    blo_fknee, infile=infile, /goodpix,interval=[0.2, 15.], /plot
;==================================================================

