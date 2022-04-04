; bias offset determination

pro test, ifile

ubiasoffs = [0.00000,0.00004,0.00008,0.00016,0.00032]

path0= '/data1/SPIRE_PFM_PLW/'			       
path = path0+'20040601/'			       

; Read the x structure data into the memory
;restore, path+'loadcrv_20040601.sav'
restore, path+'20040601.sav'

nchannel = n_elements((*x[0]).ubolo[*,0])

     
gp = blo_getgoodpix(path=path0)


if n_params() EQ 0 then ifile = 0

for channel=0, nchannel-1 do begin

  ix = where(strcompress((*x[0]).ubolo_label[channel], /rem) EQ gp,cnt)
  if cnt GT 0 then begin	;use only good pixels

    !p.multi=[0,5,1]

    for iub = 0, 4 do begin

      ubias = reform((*x[ifile]).ubias)+ubiasoffs[iub]
      ubolo = reform((*x[ifile]).ubolo[channel, *])

      a = bolodark_moffset( ubolo, ubias)
      if a[1] EQ 0 then uboloc=ubolo $
      else uboloc = reform(ubolo)-a[0]
      
      if iub EQ 0 then xrange=[min(ubias), max(ubias)]
      plot, abs(ubias), abs(uboloc) , xrange=xrange    
    endfor

    c = get_kbrd(1)
  endif else begin

  endelse

endfor


end


