@def_user_common
@def_phys_common
@def_cosmo_common
@def_bolo_common
@def_astro_common
@hist_wrapper
@prob_norm
@str_sep
; Useful for analyzing any situation where you have DC level data in
; various positions (paddling M2, for example)

; position specifies the label to attach to each.  For the DC levels the OUT
; or OFF position 'O' is important.

; keyword /edge plots approximate edge tapers for paddling M2

; keyword /zoom plots zoom of edge positions (when the first position
; after the 'out' is center).  Useful when pretty well-centered, but
; trying to tweak to get the outside positions even.

; The default behavior is to assume the load is HOT, in which case
; lower DC voltages mean more power, so the sign of the offset
; subtracted voltage is flipped.  You can specify a COLD load, meaning
; that the paddle in the beam gives a higher voltage (lower loading
; with respect to the background) with the /cold keyword.

pro analyze_dc_loads, ncdf_file, positions, cold=cold, edge=edge, zoom=zoom,$
                      bolos = bolos, flag = flag, sig = sig, $
                      fitgauss = fitgauss, yrange_fitgauss=yrange_fitgauss,$
                      yrange_edge=yrange_edge

load_plot_colors
!cols.(0)=-1
; Starting from a ncdf_file, analyze

; This bit is a module that should be pulled out, since it's common to
; all our dealings with test data

goodbolos = intarr(160)+1
goodbolos[81] = 0.

flag = read_ncdf(ncdf_file,'nodding')
bolos = read_ncdf(ncdf_file,'ac_bolos')
ntod = n_e(bolos[0,*])
; Unbelievable
t = read_ncdf(ncdf_file,'ticks')
si = find_sample_interval(t)

; Slice out the useful data
trans = find_transitions(flag)

; Go through and get the DC offsets
off = dblarr(160)

whoff = where(positions eq 'O')
; Number of positions that aren't an off
wh = where(positions ne 'O',npos)

for i = 0,160-1 do begin
    off[i] = median(bolos[i,trans.rise[whoff] : trans.fall[whoff]])
endfor

;if npos ne 4 then message,'Seriously?  What are you doing?'

sig = dblarr(160,npos)
indx = lindgen(npos)

for i=0,npos-1 do begin

    for j=0,160-1 do begin
      
        sig[j,i] = $
          -(median(bolos[j,trans.rise[wh[i]] : trans.fall[wh[i]]]) - off[j])
        if (keyword_set(cold)) then sig[j,i] *= -1.
        
    endfor

endfor

nu = freqid2freq()

cols = intarr(npos)
for c = 0,npos-1 do begin
    cols[c] = !cols.(c)
endfor

plot,nu,sig[*,0]/goodbolos,/xst,psy=10,col=cols[0],$
     xtit='Frequency (GHz)',ytit='V RMS',/yst,yr=[-0.001,max(sig)*1.5],$
  tit=ncdf_file,xr=[180,310]

for i=1,npos-1 do begin

   oplot,nu,sig[*,i]/goodbolos,psy=10,col=cols[i]

endfor


legend,positions[wh],textcol=cols,charsize=3


;stop

if keyword_set(zoom) then begin
window,!d.window+1

plot,nu,sig[*,0]/goodbolos,/xst,psy=10,col=cols[0],$
     xtit='Frequency (GHz)',ytit='V RMS',/yst,yr=[0,max(sig[10:150,1:4])*1.3],$
  tit=ncdf_file+' Zoomed outside positions',/nodata,xrange=[180,310]

for i=1,npos-1 do begin
   oplot,nu,sig[*,i]/goodbolos,psy=10,col=cols[i]
endfor

legend,positions[wh[1:4]],textcol=cols[1:4],charsize=3

endif

if keyword_set(edge) then begin
window,!d.window+1
if not keyword_set(yrange_edge) then yrange_edge=[0,14]
plot,nu,-10.*alog10(sig[*,1]/sig[*,0])/goodbolos,$
  tit=ncdf_file+'  Approximate edge tapers',$
  psy=10,/nodata,xrange=[180,310],/xst,yrange=yrange_edge

for i=1,npos-1 do begin
   oplot,nu,-10.*alog10(sig[*,i]/sig[*,0])/goodbolos,$
     psy=10,col=cols[i]
endfor

legend,positions[wh[1:4]],textcol=cols[1:4],charsize=3,/bot

;;nominal values based on the size of the paddle,in offsets of one cm:
edge_wav=[1.0,1.1,1.2,1.3,1.4,1.5,1.6]
edge_fqr=(3.e8*1.e3/edge_wav)*1.e-9


tap0=[11.6575,11.0767,10.5041,9.94583,9.40630,8.88880,8.39543]
tap1=[9.85863,9.33218,8.81649,8.31743,7.83825,7.38171,6.94912]
tap2=[13.9669,13.3288,12.6946,12.0716,11.4648,10.8785,10.3151]


oplot,edge_fqr,tap0,psym=-2
oplot,edge_fqr,tap1,psym=-2
oplot,edge_fqr,tap2,psym=-2

endif

if (keyword_set(fitgauss)) then begin
; Fit a Gaussian to the sig variable, bolometer by bolometer.  This
; only really makes sense if you've done a cut across a mirror, i.e.,
; it doesn't parse the positions to try to do a five-point.

gfit = dblarr(4,160)

; Positions are numbered from 1
npos = n_e(sig[0,*])
if npos ne 11 then message,'I can''t deal with that'
; Each spacing on the mirror is 2"
x = (findgen(npos)-5.)*2.*25.4 ; in mm

xfine = interpol(x,100)

;set_plot,'ps'
;device,file=ncdf_file+'fit.ps'

for i=0,159 do begin
    
    fit = gaussfit(x,sig[i,*],a,nterms=4) 
    
    plot,x,sig[i,*],/xst,psy=10,tit='Bolo '+strcompress(i,/rem)
    oplot,x,fit,col=2
    
    gfit[*,i] = a
    
;    blah = ''
;    read, blah
    
endfor

nu = freqid2freq()

plot,nu,gfit[0,*],psy=10,/xst,xtit='Frequency (GHz)',ytit='Amplitude'

blah = ''
read, blah

plot,nu,gfit[1,*],psy=10,/xst,xtit='Frequency (GHz)',ytit='Offset (mm)'

blah = ''
read, blah

if not keyword_set(yrange_fitgauss) then yrange_fitgauss=[0,200]
plot,nu,gfit[2,*]*sigma_to_fwhm(),psy=10,$
  /xst,xtit='Frequency (GHz)',ytit='FWHM (mm)',yrange=yrange_fitgauss

;fwhm_freq = 3.d8/([1.0,1.3,1.6]*1.d-3)/1.d9
;fwhm_mm = [98.9,112.92,120.42];

;oplot,fwhm_freq,fwhm_mm,psy=-2,col=2;;


fwhm_wav=[1.0,1.1,1.2,1.3,1.4,1.5,1.6]
fwhm_fqr=(3.e8*1.e3/fwhm_wav)*1.e-9


fwhm_mean=[[ 99.1500,103.174,107.411,111.838,116.434,121.179,126.056],$
	[103.547,107.804,112.286,116.965,121.820,126.830,131.977],$
	[107.967,112.458,117.182,122.112,127.225,132.499,137.915]]


for j=0,2 do oplot,fwhm_fqr,fwhm_mean(*,j),color=cols(1),psym=-2

endif

;stop

;surface,sig,/lego

;stop

end
