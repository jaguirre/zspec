;===========================================================================
;  
; Plot line strength data depending on chopper frequency
;
; Determine time constants
;
; 2003/10/02 L. Zhang  
;===========================================================================

PRO  blo_timeconst_20030720_b2

     ;Data path
     path = '/data1/SPIRE_CQM/20030720/'
     ;find the good pixel labels and the nubmer of good pixels
     goodpx = blo_getgoodpix()      
     npix = n_elements(goodpx)      

     ;log file name and path
     logfname = path+'20030720_b2_frequ.txt'

      
     ;Determine the time constant and sigma/tau ration
     blo_get_time_constant,logfname,goodpx,tau,sigma_over_tau,path=path,/d83,/plot

     openw, un,  path+'timeconst_20030720_b2.txt',/get_lun
     printf, un, systime()
     printf, un
     printf, un, 'pixel', 'tau', 'sigma/tau', format='(a12,x,a9,x,a9)'
     printf, un, '--------------------------------'

     for ipix=0, npix-1 do begin
       printf, un, goodpx[ipix], tau[ipix], sigma_over_tau[ipix], format='(a12,x,f9.6,x,f9.6)'
    endfor


     free_lun, un


     !p.multi=0
     psterm, file=path+'blo_timeconst_20030720_b2.ps'

END


