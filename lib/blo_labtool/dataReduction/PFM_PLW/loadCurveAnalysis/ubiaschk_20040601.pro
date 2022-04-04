pro ubiaschk_20040601, ifile

common amoeb, T, P, Tc


;psinit

;ubiasoffs = 0.00004

ubiasoffs = [0.00000,0.00004,0.00008,0.00016,0.00032]

path0= '/data1/SPIRE_PFM_PLW/'			       
path = path0+'20040601/'			       


;Read the load resistance from a file
bolo_read_rload, Rload1, Rload2, path=path, filename='Rload.txt'
     
     
Rload=Rload1+Rload2
   
; Read the x structure data into the memory
;restore, path+'loadcrv_20040601.sav'
restore, path+'20040601.sav'

nchannel = n_elements((*x[0]).ubolo[*,0])

     
gp = blo_getgoodpix(path=path0)

;startparams for g0 and beta

G0=dblarr(nchannel) + 4e-11 
Beta=dblarr(nchannel)+1.50d0

if n_params() EQ 0 then ifile = 0

for channel=0, nchannel-1 do begin

  ix = where(strcompress((*x[0]).ubolo_label[channel], /rem) EQ gp,cnt)
  if cnt GT 0 then begin

    !p.multi=[0,5,1]

    for iub = 0, 4 do begin

      ubias = reform((*x[ifile]).ubias)+ubiasoffs[iub]
      ubolo = reform((*x[ifile]).ubolo[channel, *])
      Tc =    reform((*x[ifile]).t_c)
      bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=Rload[channel]
      ubolo=uboloc
      R_chan=abs(ubolo/ibias)
      P_chan=abs(ubolo*ibias)

      bolodark_r_lowpow2,  ubolo, ubias, Tc, R, T , RLC=Rload[channel]
      R = abs(R)


      dp = 4
      
      if iub EQ 0 then xrange=[min(R_chan), max(R_chan)]
      plot, R_chan, P_chan , xrange=xrange    
    endfor

c = get_kbrd(1)
  endif else begin

  endelse

endfor


end


