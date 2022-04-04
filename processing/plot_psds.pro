function plot_psds,avepsd_struct, filename, chop_freq = chop_freq,$
               fitparams = fitparams
cleanplot,/sil

freq = avepsd_struct.freq
psd = avepsd_struct.psd

; Let's try to put this into RTI units ... should be nV/rtHz
gain = 160.
psd = psd / gain * 1.d9

yrange = median(psd)*[0.1,10]
;[10.,1000.]
;[2.5d-6,2.5d-4]

nnods = n_e(avepsd_struct.psd[0,*,0])
len = n_e(avepsd_struct.psd[0,0,*])

psds = fltarr(160,len)
for i=0,159 do psds[i,*] = sqrt(total(reform(psd[i,*,*]^2),1)/nnods)

; Do some fitting to PSDs ... for now, everything is hardcoded
fitparams = fltarr(160,3)
fknee = fltarr(160)
maxfreq = min([3.5,2.*chop_freq-0.2])
for i=0,160-1 do begin
    whw = find_nearest(freq,3.)
    w = psds[i,whw]
    alpha = 1.d
    f0 = 1.*w^(1./alpha)
    p0 = [f0,alpha,w]
; Gotta avoid the fundamental and second harmonic
    whfit = where((freq ge 0.1 and freq le chop_freq-.2) or $
                  (freq ge chop_freq+.2 and freq le 2.*chop_freq-.2))
; Weight by the psd itself
    fitparams[i,*] = mpfitfun('pinknoise_fun', /quiet,$
                              freq[whfit], psds[i,whfit], $
                              psds[i,whfit], p0) 
    fknee[i] = fitparams[i,0]/fitparams[i,2]^(1./fitparams[i,1])

endfor

set_plot,'ps'
device,file=filename,/color

nu = freqid2freq(indgen(160))

for p = 0,10-1 do begin

    erase
    cleanplot,/sil

    for c=0,16-1 do begin

        ch = p*16 + c

        if (c eq 0) then begin
            multiplot,[4,4] 
            tit = filename
        endif else begin
            multiplot 
            tit =''
        endelse

        plot,minmax(freq),yrange,$
          /xst,/yst,/nodata,charsize=0.75,/ylog,$
          tit=tit
        for i=0,nnods-1 do oplot,freq,psd[ch,i,*],thick=0.5,line=2
        oplot,freq,psds[ch,*],thick=4,col=2
        oplot,freq,pinknoise_fun(freq,fitparams[ch,*]),col=4
        oplot,freq,replicate(fitparams[ch,2],n_e(freq)),col=3

        if (keyword_set(chop_freq)) then oplot,[1,1]*chop_freq,yrange,$
          col=3

;        legend,/top,/right,box=0,[string(ch,format='("Ch ",I3)'),$
;                                  string(nu[ch],format='(F5.1," GHz")')],$
;         charsize=0.5

        xyouts,max(freq)/2,max(yrange)*0.5,$
          string(ch,nu[ch],$
                 format='(I3," / ",F5.1)'),$
          charsize=0.75,charthick=4,color=4

        xyouts,max(freq)/5.5,min(yrange)*1.5,$
          string(fknee[ch],$
                 format='(F5.1)'),$
          charsize=0.75,charthick=4,color=4     

     endfor

endfor

erase
cleanplot,/sil   

whchop = find_nearest(freq,chop_freq)
fitnoise = fltarr(160)
for i=0,160-1 do fitnoise[i] = $ 
  pinknoise_fun(freq[whchop],fitparams[i,*])

hfitnoise = hist_wrapper(fitnoise,(max(fitnoise)-min(fitnoise))/30.,$
                      min(fitnoise),max(fitnoise))
plot,hfitnoise.hb,hfitnoise.hc,psy=10,/xst,xtit='Fitted Noise at Chop Freq'

white = fitparams[*,2]
hwhite = hist_wrapper(white,(max(white)-min(white))/30.,$
                      min(white),max(white))
oplot,hwhite.hb,hwhite.hc,psy=10,col=2

; -----------------------

erase
cleanplot,/sil

plot,nu,fitnoise,psy=10,/xst,xtit='Frequency (GHz)',$
  ytit='Fitted Noise'

erase
cleanplot,/sil

hfknee = hist_wrapper(fknee,0.5,0,20)
plot,hfknee.hb,hfknee.hc,psy=10,/xst,xtit='Knee Freqency [Hz]'

erase
cleanplot,/sil   

alpha = fitparams[*,1]
halpha = hist_wrapper(alpha,(max(alpha)-min(alpha))/30.,$
                      min(alpha),max(alpha))
plot,halpha.hb,halpha.hc,psy=10,/xst,xtit='Alpha'

device,/close
set_plot,'x'

cleanplot,/sil

return,create_struct('fnee',fknee,$
                     'f_o',reform(fitparams[*,0]),$
                     'alpha',reform(fitparams[*,1]),$
                     'white',reform(fitparams[*,2]),$
                     'fitnoise',fitnoise,$
                     'gain',gain)


end
