;==================================================================
; NAME          :  bolo_g0_beta_20031006.prob
;   
; DESCRIPTION	:  Calcualte G0 and Beta
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is load curve data reduction  STEP 5
;
;==================================================================
 
 pro bolo_g0_beta_20031006
     
     
      path='/data1/SPIRE_PFM_SLW/20031006/'			       

     
     ;Rstore the Rstar and Tstar from a file
     bolo_restore_rstar_tstar, Rstar, Tstar, path=path, $
             filename='bolo_rstar_tstar_20031006.txt'
     
   
     ;Read the load resistance from a file
     bolo_read_rload, Rload1, Rload2, path=path, filename='Rload.txt'
     
     
     Rload=Rload1+Rload2
    
     
     ; Read the x structure data into the memory
     restore, path+'loadcrv_20031006.sav'
 
     ;select temperature stable measurements
     ixt = bolodarkx_tdrift(x, limit=0.005, tfract=0.10)
     xx = x[ixt]

     
     nchannel = n_elements((*xx[0]).ubolo[*,0])
     
     ;Tbath=0.2575d
     ;common_name_str='_20031006_0.2575hmK'
     
     Tbath=0.257d
     common_name_str='_20031006_0.257mK'
     
     ;Calling the fit routine to get G0 and Beta
      bolo_get_g_beta, xx, Rstar, Tstar,G0, Beta,  Rload=Rload, T_c=Tbath
     
     ; Write the G0 and Beta to a file     
     openw, un, path+'bolo_rstar_tstar_g0_beta'+common_name_str+'.txt', /get_lun
     printf, un, 'Channel', 'Rstar', 'Tstar',  'G0 (pW/K)', 'Beta', $
  	        form='(a10,x,a10,x,a10,x,a10,x,a10)'
     printf, un, '--------------------------------------------------------'
  
     ;change the G0 unit to pW/K, by mutiplying 1e12
     for i=0, nchannel-1 do begin
          printf, un, (*x[0]).ubolo_label[i], Rstar[i], Tstar[i], $
      	          G0[i]*1e12, Beta[i], $
	          form='(a10,5x,f6.2,5x,f6.2,5x,f6.2,5x,f6.2)'
     endfor
     free_lun, un
    									        
    ;Plot LnR vs Power							        
    !p.multi=0							        
    psinit, /full, /letter, /color					        
    bolo_plot_lnr_vs_power, xx,  Rstar, Tstar, G0, Beta, /T0 , Rload=Rload, T_c=Tbath   
    !p.multi= 0								      
    psterm, file=path+'LnR_LnP'+common_name_str+'.ps'				        
    
    ;make Power vs T plot       					        
    !p.multi=[0,2,4]							        
    									       
    psinit, /full, /letter, /color				   	        
    bolo_plot_power_vs_t, xx,  Rstar, Tstar, G0, Beta, Rload=Rload, T_c=Tbath  	        
    !p.multi=0  						   	        
    psterm, file=path+'Power_vs_T'+common_name_str+'.ps' 		   	        
    									        
    psinit, /full, /letter, /color				   	        
    bolo_plot_voltage_vs_current, xx,  Rstar, Tstar, G0, Beta, Rload=Rload, T_c=Tbath	        
    !p.multi=0  						   	        
    psterm, file=path+'voltage_vs_current'+common_name_str+'.ps'  		   	        

    
 
END    
