pro pvsT_20040601

common amoeb, T, P, Tc


psinit

ubiasoffs = 0.0 ;0.00004

path0= '/data1/SPIRE_PFM_PLW/'			       
path = path0+'20040601/'			       


;Rstore the Rstar and Tstar from a file
bolo_restore_rstar_tstar, Rstar, Tstar, path=path, $
        filename='bolo_rstar_tstar_20040601.txt'

;Read the load resistance from a file
bolo_read_rload, Rload1, Rload2, path=path, filename='Rload.txt'
     
     
Rload=Rload1+Rload2
   
; Read the x structure data into the memory
restore, path+'loadcrv_20040601.sav'

nchannel = n_elements((*x[0]).ubolo[*,0])

common_name_str='_20040601'
     
gp = blo_getgoodpix(path=path0)

;startparams for g0 and beta
G0=dblarr(nchannel) + 4e-11 
Beta=dblarr(nchannel)+1.50d0

Tc = 0.25
common_name_str='_20040601b'

ifile = 0

for channel=0, nchannel-1 do begin

  ix = where(strcompress((*x[0]).ubolo_label[channel], /rem) EQ gp,cnt)
  if cnt GT 0 then begin


      ubias = reform((*x[ifile]).ubias)+ubiasoffs
      ubolo = reform((*x[ifile]).ubolo[channel, *])                                       
      bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=Rload[channel]
      ubolo=uboloc
      R_chan=abs(ubolo/ibias)
      P_chan=abs(ubolo*ibias)
      LnR=alog(R_chan)
      LnRstar = alog(Rstar[channel])
      T_chan = Tstar[channel]/(LnR - LnRstar)^2
      ix  = where(finite(T_chan) eq 1 AND P_chan GT 1e-13, cnt ) 
      T   = T_chan[ix]
      P   = P_chan[ix]  

      dp = 4.0
      
      if channel EQ 0 then $
      plot, T, P*1e12+channel*dp, psym=3, charsize=1.6, title='PFM PLW' $
        ,xtitle='T [K]', ytitle='P [pW]' $
        ,xthick=4, ythick=4, xmargin=[8,3] $
        , xrange=[0.24,0.75], yrange=[0,dp*nchannel*1.3], xstyle=3, ystyle=1 $
        ,/nodata
      
      oplot, T, P*1e12+channel*dp, psym=3               ;plot data
      oplot, [0.1,0.6],[0.,0.], linestyle=1

      ix2 = where(max(T) EQ T)

;     xyouts, T[ix2], P[ix2]*1e12+channel*dp+0.01, (*x[0]).ubolo_label[channel] $

      xyouts, 0.72, channel*dp*1.2+10, (*x[0]).ubolo_label[channel] $
          , charsize=0.6
      xyouts, 0.27, 230, 'P shifted up by 4pW for each channel'

      
; fit G0 and beta
      
      a0 = G0[channel]
      a1=Beta[channel]+1.d0                               
            
      a = [a0, a1]                                        
         
      R = AMOEBA(1.0e-5, SCALE=[1e-10,100.], P0 = a, FUNCTION_VALUE=fval, $
                  function_name='bolodark_amoebafunc_rvs')
      if n_elements(r) EQ 2 then a = r

      P1 = a[0] * (0.3^(-(a[1]-1.d)) * ((T)^a[1]-(Tc)^a[1]) / a[1])

      G0[channel]=a[0]                                 
      Beta[channel]=a[1]-1.d0    
           
      print, G0[channel], Beta[channel]
      oplot, T, P1*1e12+channel*dp

  endif else begin
      G0[channel]=0.0                                 
      Beta[channel]=0.0 
  endelse

endfor

psterm , file=path+'pvsT'+common_name_str+'.ps'


openw, un, path+'bolo_rstar_tstar_g0_beta'+common_name_str+'.txt', /get_lun
printf, un, 'Channel', 'Rstar', 'Tstar',  'G0 (pW/K)', 'Beta', $
           form='(a10,x,a10,x,a10,x,a10,x,a10)'
printf, un, '--------------------------------------------------------'
  
for i=0, nchannel-1 do begin $
          printf, un, (*x[0]).ubolo_label[i], Rstar[i], Tstar[i], $
      	          G0[i]*1e12, Beta[i], $
	          form='(a10,5x,f6.2,5x,f6.2,5x,f6.2,5x,f6.2)'
     endfor
     free_lun, un

end


