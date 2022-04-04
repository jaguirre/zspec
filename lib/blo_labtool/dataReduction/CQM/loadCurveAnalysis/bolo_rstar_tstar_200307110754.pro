;==================================================================
;  
; NAME		:  bolo_rstar_tstar_200307110754
;   
; DESCRIPTION	:  Calculate Rstar (R0) and Tstar (Del)
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction STEP 4
;
; 2004/02/04    modified for CQM   B.Schulz
;==================================================================
PRO bolo_rstar_tstar_200307110754
   								       
     path='/data1/SPIRE_CQM/20030711/'			       
        							       
     ;Read the load resistance from a file			       
     bolo_read_rload, Rload1, Rload2, path=path, filename='Rload.txt' 
     
     Rload=Rload1+Rload2					       
     ; Read the x structure data into the memory		       
     restore, path+'loadcrv_200307110754.sav'								       

     ;select temperature stable measurements			       
     ixt = bolodarkx_tdrift(x, limit=0.005, tfract=0.10)	       
     xx = x[ixt]						       
     nchannel = n_elements((*xx[0]).ubolo[*,0]) 		       

     !p.multi=[0,2,4]
     psinit, /full, /letter, /color
     
    
     ;give initial prameters
     ;bolodarkx_rtstar, xx, Rstar0, Tstar0, Rload=Rload, /slope,/plot
     bolodarkx_rtstar, xx, Rstar0, Tstar0, Rload=Rload, /plot
     
     !p.multi=0
     psterm, file=path+'lnRT200307110754.ps'
     
 
     openw, un, path+'bolo_rstar_tstar_200307110754.txt', /get_lun
     printf, un, 'Channel', 'Rstar0', 'Tstar0',  $
 		 form='(a10,x,a10,x,a10)'
     printf, un, '--------------------------------------------'
   
     for i=0, nchannel-1 do begin
         printf, un, (*xx[0]).ubolo_label[i], Rstar0[i], Tstar0[i], $
 		   ;form='(a10,x,f12.6,x,f12.6)'
   		   form='(a10,x,e12.6,x,e12.6)'
     endfor
     
     free_lun, un
END    
