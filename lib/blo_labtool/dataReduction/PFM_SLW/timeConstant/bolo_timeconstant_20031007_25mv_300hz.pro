;========================================================================
; NAME		:  bolo_timeconstant_20031007_25mv_300hz
;
; DESCRIPTION	:  Determine time constants
; 		   Plot line strength data depending on chopper frequency
; 
; 2003/10/14    :  L. Zhang
;
; NOTE		:  This is time constant data reduction STEP 5
;========================================================================

PRO  bolo_timeconstant_20031007_25mv_300hz

     ;Data path
     path = '/data1/SPIRE_PFM_SLW/20031007/25mV_300Hz_4096pts/'
 
    ;find the good pixel labels and the nubmer of good pixels
     goodpx = blo_getgoodpix()      
     npix = n_elements(goodpx)      
     ;log file name and path
     logfname = path+'20031007_25mV_300Hz_4096pts_frequ.txt'
      
     ;Determine the time constant and sigma/tau ration
     bolo_get_time_constant,logfname,goodpx,tau,sigma_over_tau,path=path,/plot

     openw, un,  path+'bolo_timeconst_20031007_25mV_300Hz_4096pts.txt',/get_lun
     printf, un, systime()
     printf, un
     printf, un, 'pixel', 'tau', 'sigma/tau', format='(a12,x,a9,x,a9)'
     printf, un, '--------------------------------'

     for ipix=0, npix-1 do begin
       printf, un, goodpx[ipix], tau[ipix], sigma_over_tau[ipix], format='(a12,x,f9.6,x,f9.6)'
    endfor


     free_lun, un


     !p.multi=0
     psterm, file=path+'bolo_timeconst_20031007_25mV_300Hz_4096pts.ps'

END


