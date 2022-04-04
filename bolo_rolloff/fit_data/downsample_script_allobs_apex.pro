
obslist=!zspec_pipeline_root+'/bolo_rolloff/fit_data/'+$
  'obsdates_apex_jan.txt'

readcol,obslist,obsnights,format='(A10)'

for count=0,n_e(obsnights)-1 do begin

if count eq 0 then $
  files=file_search(!zspec_data_root+$ 
  '/apexnc/*/*'+obsnights[count]+'*.nc*') $
  else $
  files=[files,file_search(!zspec_data_root+$
                  '/apexnc/*/*'+obsnights[count]+'*.nc*')]

endfor


;stop

rebin_fac = 75L

for i=0,n_e(files)-1 do begin

    
if1= strmid(files(i),4,5,/rev) eq 'empty'
if3= strmid(files(i),3,4,/rev) eq 'nobe'
if i ne n_e(files)-1 then if2= strmid(files(i+1),4,5,/rev) eq 'empty' else if2=if1
if i ne n_e(files)-1 then if4= strmid(files(i+1),3,4,/rev) eq 'nobe' else if4=if3

file_out = change_suffix(files[i],'_dc_curve.sav')
	fs=file_search(file_out)
	if fs(0) ne '' then spawn,'rm '+fs 

 if ~if1 and ~if2 and ~if3 and ~if4 then begin   
 print,files[i]
    zipped=0

    ;now unzip it if it is a gzipped file
    filetype=strmid(files[i],0,/reverse)
    if filetype eq 'z' then begin
       gzfile=files[i]
       SPAWN, 'gunzip ' + gzfile
       files[i]=change_suffix(gzfile,'nc')
       zipped=1
    endif

 ;;;gah, this is all wrong now for APEX data   
    sinbolos = read_ncdf(files[i],'sin')
    cosbolos = read_ncdf(files[i],'cos')
    ticks = read_ncdf(files[i],'ticks')
    
    sinbolos = read_ncdf(files[i],'sin')
    cosbolos = read_ncdf(files[i],'cos')
    
    bias = get_bias_apex(files[i])
    temps = get_temps_apex(files[i])
    
    typtemps=size(temps,/tname)
if typtemps eq 'STRUCT' then begin
    grt1 = temps.grt1
    grt2 = temps.grt2

    sampint = find_sample_interval(ticks)
;    sampint = find_sample_interval_naylor(ticks)
PRINT, 'Sample Interval = ', sampint, $
       ', -> Bias Frequency = ', 2./sampint, ' Hz'
; Work around the stupid 20000 padding problem
    mask = where(fin_diff(ticks) ne 0)

; Resize everything to the mask
;rebin first
;;do some stupid rounding
ssin=(size(sinbolos))(2)

if ssin ge 100 then begin
;msin=ssin mod 25
;if msin ne 0 then begin
;	sinbolos=sinbolos(*,0:ssin-msin-1);
;	cosbolos=cosbolos(*,0:ssin-msin-1);
;	endif
	
    ;sinbolosrbn = rebin(sinbolos,10,25)
    ;cosbolosrbn = rebin(cosbolos,10,25)
    

    sinbolos = sinbolos[*,mask]
    cosbolos = cosbolos[*,mask]
    ticks = ticks[mask]
    bias = bias[mask]
    grt1 = grt1[mask]
    grt2 = grt2[mask]
    
    
    ;throw away outliers
    
    nbolos=(size(sinbolos))(1)
    mask2=lonarr(n_e(bias))
    
    for jj=0,nbolos-1 do begin
    sx=sinbolos(jj,*)
    cx=cosbolos(jj,*)
    u=where(~finite(sx) or ~finite(cx),complement=nu)
    if u(0) ne -1 then begin
    	mask2(u)=1
    	sx=sx(nu)
    	cx=cx(nu)
    endif
    s1=stddev(sx)
    s2=stddev(cx)
    
    ;u2=where(sx ge 5.*s1 or cx ge 5.*s2)
    ;if u2(0) ne -1 then mask2(u2)=1
    
    
    u3=where(abs(sx) gt 1. or abs(cx) gt 1.)
    if u3(0) ne -1 then mask2(u3)=1
    
    endfor
    
    ctx=where(mask2 ne 1)
  if ctx(0) ne -1 then begin
    
    sinbolos = sinbolos[*,ctx]
    cosbolos = cosbolos[*,ctx]
    ticks = ticks[ctx]
    bias = bias[ctx]
    grt1 = grt1[ctx]
    grt2 = grt2[ctx]
    print,max(sinbolos),max(cosbolos)
; Throw away odd bit at the end
    ntod = n_e(bias)
    ntod_min = ntod/rebin_fac
    mxpt=ntod_min*rebin_fac
if mxpt gt 0 then begin

    sinbolos = sinbolos[*,0 : mxpt - 1]
    cosbolos = cosbolos[*,0 : mxpt - 1]
    bias = bias[0:mxpt - 1]
    ticks = ticks[0:mxpt - 1]
    grt1 = grt1[0:mxpt - 1]
    grt2 = grt2[0:mxpt - 1]

; And rebin
    sinbolosmean = rebin(sinbolos,160,ntod_min)
    cosbolosmean = rebin(cosbolos,160,ntod_min)
    sinbolos2mean = rebin(sinbolos^2,160,ntod_min)
    cosbolos2mean = rebin(cosbolos^2,160,ntod_min)
    sinboloserr = SQRT((rebin_fac/FLOAT(rebin_fac - 1))*$
                       (sinbolos2mean - sinbolosmean^2))/SQRT(rebin_fac)
    cosboloserr = SQRT((rebin_fac/FLOAT(rebin_fac - 1))*$
                       (cosbolos2mean - cosbolosmean^2))/SQRT(rebin_fac)

    sinbolos = sinbolosmean
    cosbolos = cosbolosmean
    bias = rebin(bias,ntod_min)
    ticks = rebin(ticks,ntod_min)
    grt1 = rebin(grt1,ntod_min)
    grt2 = rebin(grt2,ntod_min)
    
    ;;weed out tiny errors?
    
    
; Write the output file
    file_out = change_suffix(files[i],'_dc_curve.sav')

    save,sinbolos,sinboloserr,cosbolos,cosboloserr,$
         bias,ticks,grt1,grt2,sampint,$
         file = file_out

;rezip the file if it was originally zipped
if zipped eq 1 then $
  SPAWN, 'gzip ' + files[i]

endif
endif
endif else begin
	file_out = change_suffix(files[i],'_dc_curve.sav')
	fs=file_search(file_out)
	if fs(0) ne '' then spawn,'rm '+fs 
endelse	

endif else begin
	file_out = change_suffix(files[i],'_dc_curve.sav')
	fs=file_search(file_out)
	if fs(0) ne '' then spawn,'rm '+fs 
endelse	
;; get rid of bad files at the end

endif else begin
	file_out = change_suffix(files[i],'_dc_curve.sav')
	fs=file_search(file_out)
	if fs(0) ne '' then spawn,'rm '+fs 
endelse	

endfor

end
