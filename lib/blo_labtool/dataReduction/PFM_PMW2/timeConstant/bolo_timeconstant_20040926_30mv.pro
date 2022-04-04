;========================================================================
; NAME		: bolo_timeconstant_20040926_30mv
;
; DESCRIPTION	: Determine time constants
; 		  Plot line strength data depending on chopper frequency
;
; 2004/09/30    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 5
;========================================================================

PRO  bolo_timeconstant_20040926_30mv

     ;Data path
     path = '/data1/SPIRE_PFM_PMW2/20040926/30mV/'
 
    ;find the good pixel labels and the number of good pixels
     goodpx = blo_getgoodpix()      
     npix = n_elements(goodpx)      
     ;log file name and path
     logfname = path+'20040926_30mV_frequ.txt'
      
     ;Determine the time constant and sigma/tau ratio
     bolo_get_time_constant,logfname,goodpx,tau,sigma_over_tau,path=path,/plot

     openw, un,  path+'timeconst_20040926_30mV.txt',/get_lun
     printf, un, systime()
     printf, un
     printf, un, 'pixel', 'tau', 'sigma/tau', format='(a12,x,a9,x,a9)'
     printf, un, '--------------------------------'

     for ipix=0, npix-1 do begin
       printf, un, goodpx[ipix], tau[ipix], sigma_over_tau[ipix], format='(a12,x,f9.6,x,f9.6)'
    endfor


     free_lun, un


     !p.multi=0
     psterm, file=path+'bolo_timeconst_20040926_30mV.ps'

END


