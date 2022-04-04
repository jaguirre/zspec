

files = file_search(!ZSPEC_DATA_ROOT + $
                    '/ncdf/20090114/20090114_03[7-8].nc.gz')

;files = [files,file_search(!ZSPEC_DATA_ROOT + $
;                    '/ncdf/20090114/20090114_0[4-5]*.nc.gz')]


;files = [files,file_search(!ZSPEC_DATA_ROOT + $
;                    '/ncdf/20090113/20090113_0[1-4]*.nc.gz')]

rebin_fac = 200L

for i=0,n_e(files)-1 do begin
   gzfile = files[i]
   ncfile = change_suffix(gzfile,'nc')
   SPAWN, 'gunzip ' + gzfile

    print,ncfile
    
    sinbolos = read_ncdf(ncfile,'sin')
    cosbolos = read_ncdf(ncfile,'cos')
    ticks = read_ncdf(ncfile,'ticks')
    bias = get_bias(ncfile)
    temps = get_temps(ncfile)
    grt1 = temps.grt1
    grt2 = temps.grt2

    sampint = find_sample_interval(ticks)
PRINT, 'Sample Interval = ', sampint, $
       ', -> Bias Frequency = ', 2./sampint, ' Hz'
; Work around the stupid 20000 padding problem
    mask = where(fin_diff(ticks) ne 0)

; Resize everything to the mask
    sinbolos = sinbolos[*,*,mask]
    cosbolos = cosbolos[*,*,mask]
    ticks = ticks[mask]
    bias = bias[mask]
    grt1 = grt1[mask]
    grt2 = grt2[mask]

; Throw away odd bit at the end
    ntod = n_e(sinbolos[0,0,*])
    ntod_min = ntod/rebin_fac

    sinbolos = sinbolos[*,*,0 : ntod_min*rebin_fac - 1]
    cosbolos = cosbolos[*,*,0 : ntod_min*rebin_fac - 1]
    bias = bias[0:ntod_min*rebin_fac - 1]
    ticks = ticks[0:ntod_min*rebin_fac - 1]
    grt1 = grt1[0:ntod_min*rebin_fac - 1]
    grt2 = grt2[0:ntod_min*rebin_fac - 1]

; And rebin
    sinbolosmean = rebin(sinbolos,10,24,ntod_min)
    cosbolosmean = rebin(cosbolos,10,24,ntod_min)
    sinbolos2mean = rebin(sinbolos^2,10,24,ntod_min)
    cosbolos2mean = rebin(cosbolos^2,10,24,ntod_min)
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
    
; Write the output file
    file_out = change_suffix(ncfile,'_dc_curve.sav')

    save,sinbolos,sinboloserr,cosbolos,cosboloserr,$
         bias,ticks,grt1,grt2,sampint,$
         file = file_out

    SPAWN, 'gzip ' + ncfile
endfor

end
