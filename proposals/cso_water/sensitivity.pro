; Assume the following things
tsys = 150.
; Effective area of the CSO 
kperjy = k_per_jy(!pi*(10.4/2)^2.*0.7)
; Bandwidth of the backend, GHz
bwtot = 1. 
nchannel = 32
; km / s
linewidth = 350.
; km / s
chanwidth_hz = bwtot/nchannel * 1.d9
chanwidth = chanwidth_hz/(230.*1.d9) * 3.d5

nchan_per_line = linewidth / chanwidth

intbright = findgen(20)+10.
width_sn = dblarr(20)
amp_sn = dblarr(20)

; Per channel RMS in Jy
t = 8. * 3600.
chan_rms = tsys / kperjy / sqrt(t * chanwidth_hz)

; Ok, let's just make up a simulation
lc = 230.d9

hz = (findgen(nchannel)-nchannel/2)*chanwidth_hz + lc
v = (hz - lc)/lc * 3.d5

; Set FWHM = linewidth
sigma = linewidth / 2.35
line_profile = exp(-v^2/(2.*sigma^2))
norm = total(line_profile * chanwidth)

for ib = 0,n_e(intbright)-1 do begin

    line = line_profile / norm * intbright[ib]

    nrlz = 1000L
    nterms = 6
    params = dblarr(nterms,nrlz)
    
    for i = 0,nrlz-1 do begin
        
        noise = randomn(seed,nchannel)*chan_rms
        
;    plot,v,line+noise,psy=10,/xst
;    oplot,v,line,psy=10,col=2
        
;    g = gaussfit(v,line+noise,a,nterms=nterms)
        parinfo = replicate({value:0.D, fixed:0, $
                             limited:[0,0], $
                             limits:[0.D,0]},$
                            nterms) 
        parinfo(1).fixed = 1
        parinfo(5).fixed = 1
        parinfo(2).limited(0) = 1
        parinfo(2).limits(0)  = 1.D
        parinfo(*).value = [.040d,0.,250.,0.,0.,0.]
        a = mpfitfun('gauss_fun', v, line+noise, replicate(chan_rms,nchannel),$
                     parinfo=parinfo)
    
;parms = MPFITFUN(MYFUNCT, X, Y, ERR, start_params, ...)
        g = gauss_fun(v,a)

;    oplot,v,g,col=3

        params[*,i] = a

    endfor

    amp_sn[ib] = mean(params[0,*])/stddev(params[0,*])
    width_sn[ib] = mean(params[2,*])/stddev(params[2,*])

endfor

end
