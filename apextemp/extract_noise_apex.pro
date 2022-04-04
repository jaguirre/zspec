; Version 2010/09/28
; For use at APEX on illapa with TPD's nc files

pro extract_noise_apex, file_root, yrange = yrange, navg = navg, ntod = ntod

; This is from Lieko, 10 Mar 2007
; Unused channels
unused = intarr(8,24)
unused[1-1,[4, 6, 22, 23]] = 1
unused[2-1,[4, 7, 14, 16]] = 1
unused[3-1,[1, 2, 3, 7, 8, 10, 23]] = 1
unused[4-1,[6, 14, 19, 20, 21, 22]] = 1
unused[5-1,[7, 18, 19, 21]] = 1
unused[6-1,[2]] = 1
unused[7-1,[8, 9, 10]] = 1
unused[8-1,[1]] = 1

; Fixed
fixed = intarr(8,24)
fixed[6-1,[9, 23]] = 1

; nV / rtHz
if not keyword_set(yrange) then yrange = [1.d-10,1.d-6]*1.d9

!p.charsize = 1.

nbox = 10
nchan = 24

; These are now 240 by ntime
cos_in = read_ncdf(file_root+'_merged.nc','cos')
sin_in = read_ncdf(file_root+'_merged.nc','sin')
if ~keyword_set(ntod) then begin
    ntod = n_e(cos_in[0,*])
endif else begin
    ntod = ntod
endelse

; Get the timestamp and turn into jd
timestamp =  read_ncdf(file_root+'_merged.nc','timestampUDP')
jd = parse_udp_timestamp(timestamp)
sample_interval = median(fin_diff(jd[0,*])*24.*3600.d)

print,'Total number of samples is '+string(ntod,format='(I10)')
print,'corresponding to '+string(ntod*sample_interval,format='(I10)')+' sec'
print,'Sample interval is '+string(sample_interval,format='(F6.4)')+' sec'

cos = dblarr(10,24,ntod)
sin = dblarr(10,24,ntod)

for b = 0,nbox-1 do begin
    for c = 0,24-1 do begin
        cos[b,c,*] = cos_in[b*nchan + c,0:ntod-1]
        sin[b,c,*] = sin_in[b*nchan + c,0:ntod-1]
    endfor
endfor

data = replicate(create_struct('cos',dblarr(10,24),'sin',dblarr(10,24)),ntod)

for i = 0,nbox-1 do begin

    data[*].sin[i,*] = sin[i,*,*]
    data[*].cos[i,*] = cos[i,*,*]

endfor

; Extract the optical channels
optical = extract_channels(data.cos,data.sin,'optical')

; Get temperature data
jfet_diode = tempconvert(data.sin[9,1],'diode','')
cernox = tempconvert(data.sin[9,8],'cerx31187','log')
grt1 = grt_filter(tempconvert(data.sin[9,10],'grt29177','log'))
grt2 = grt_filter(tempconvert(data.sin[9,11],'grt29178','log'))

ps_file = file_root + '.ps'
sav_file = file_root + '.sav'

; Set up the PSD stuff
; Measured AC gain at 100 Hz bias frequency.
gain = 150. ;200./sqrt(2.)
if ~keyword_set(navg) then begin
    navg = 4096L
    if ntod-200 lt navg then navg = min([ntod-200,1024])
endif else begin
    navg = navg
endelse

    rload = 30.d6


vchannel_deglitch = dblarr(8,24,n_e(data))
vchannel = dblarr(8,24,n_e(data))

set_plot,'ps'
device,file=ps_file,/color,/landscape

freq = (psd(fltarr(navg),samp=sample_interval,avg=navg)).freq
xrange = minmax(freq[1:*])

vbias = (reform(sqrt(data.cos[0,12]^2 + data.sin[0,12]^2)))
vbias_deglitch = deglitch(vbias,step=1.d-2,/quiet)
vbias_mean = mean(vbias_deglitch)

vchannel_deglitch_psd = dblarr(8,24,navg/2+1)
vchannel_psd = dblarr(8,24,navg/2+1)
vchannel_psd_optical = dblarr(160,navg/2+1)

for f = 0,160-1 do begin

    vchannel_psd_optical[f,*] = (psd(optical[f,*]/gain,$
                                     samp=sample_interval,avg=navg)).psd
endfor

for b = 1,8 do begin

    erase
    cleanplot,/sil

    for i=0,23 do begin

        if (i eq 0) then begin
            multiplot,[4,6] 
        endif else begin
            multiplot 
        endelse

;        case i of 
;            3 : tit = file_root
;            0 : tit = 'Box '+strcompress(b,/rem)
;            else : tit = ''
;        endcase 

        if (i eq 1) then begin
            tit =file_root + string('Box',b,'JFET: ',mean(jfet_diode),$
                         'He3 Box: ',mean(cernox),'GRT 1: ',$
                         mean(grt1),'GRT 2: ',mean(grt2), $
                         format='('+$
                         'A4,I2,"  ",A,F7.1," K, ",A,F7.3," K, ",'+$
                         'A,F7.3," K, ",A,F7.3," K")')
        endif else begin
            tit = ''
        endelse

        vchannel[b-1,i,*] = sqrt(data.cos[b,i]^2 + data.sin[b,i]^2)/gain
        vchannel_deglitch[b-1,i,*] = $
          deglitch(reform(vchannel[b-1,i,*]),step=1.d-4,/quiet)
        vchannel_deglitch_psd[b-1,i,*] = $
;          reform((psd_scan(vchannel_deglitch[b-1,i,*]))[1,*])
        (psd(vchannel_deglitch[b-1,i,100:*],samp=sample_interval,avg=navg)).psd
        vchannel_psd[b-1,i,*] = $
;          reform((psd_scan(vchannel[b-1,i,*]))[1,*])
        (psd(vchannel[b-1,i,100:*],samp=sample_interval,avg=navg)).psd

        if ((i mod 4) eq 0) then begin
            yst = 5
        endif else begin
            yst = 1
        endelse

        

        if (unused[b-1,i]) then begin
            plot_io,freq,vchannel_psd[b-1,i,*]*1.d9,$
              /xst, xr=xrange, tit=tit, yst=yst, yr=yrange, yticks=ytcks,$
              /nodata,charsize=0.7
            xyouts,10.^mean(alog10(xrange)),10.^mean(alog10(yrange)),$
              'NOT USED',$
              charthick=3,charsize=2,align=0.5
        endif else begin 

            plot_io,freq,vchannel_psd[b-1,i,*]*1.d9,$
              /xst, xr=xrange, tit=tit, yst=yst, yr=yrange, yticks=ytcks,$
              charsize=0.7
            oplot,freq,vchannel_deglitch_psd[b-1,i,*]*1.d9,col=2
            
            dc = mean(vchannel_deglitch[b-1,i,*])
            rbolo = 2.*rload*(dc/vbias_mean)/(1.-dc/vbias_mean)
        
            whlf = where(freq ge 1 and freq le 3)
            lfnoise = sqrt(mean((vchannel_psd[b-1,i,whlf]*1.d9)^2))

; Auto range the units
            if (rbolo ge 1.d6) then begin
                units = textoidl('M\Omega')
                rbolom = rbolo / 1.d6
            endif
            if (rbolo ge 1.d3 and rbolo lt 1.d6) then  begin
                units = textoidl('k\Omega')
                rbolom = rbolo / 1.d3
            endif
            if (rbolo lt 1.d3) then  begin
                units = textoidl('\Omega')
                rbolom = rbolo
            endif

            xyouts,1,200,strcompress(i,/rem),charthick=2,charsize=1
            
            xyouts,3,300,$
              string(lfnoise,textoidl('nV Hz^{-1/2}'),dc*1.d9,rbolom,units,$
                     format=$
                     '('+$
                     '"1-3 Hz Noise: ",F8.1," ",A,"!C",'+$
                     '"DC mean:      ",F8.2," nV !C",'+$
                     '"Rbolo:        ",F8.3," ",A)'),$
              charsize=.7
            
            oplot,[1,3],[1,1]*lfnoise,col=3,thick=5
            
        endelse

        if ((i mod 4) eq 0) then begin
            axis,yaxis=0,/ylog,/yst,yr=yrange,$
              ytit=textoidl('nV Hz^{-1/2} RTI'),charsize = 0.7, $
              yticks=2,ytickv=[1,10,100],yminor=10
        endif


    endfor

endfor

device,/close_file
set_plot,'x'

multiplot,/reset
cleanplot,/silent

;b = 1
;for i=0,23 do begin
;    print,string(i,mean(vchannel_deglitch[b-1,i,*]),$
;                 stddev(vchannel_deglitch[b-1,i,*]),$
;                 format='(I2," DC mean: ",E8.2," DC stddev:",E8.2)')
;endfor    
;

help, lfnoise, dc, rbolom

flags = lonarr(160)+1
flags[81] = 0
flags[86] = 0
flags[128] = 0

avgpsd = average_psds(vchannel_psd_optical,flags,/median)

; Make a save file
save,vbias,vbias_deglitch,vchannel,vchannel_deglitch,$
  jfet_diode, cernox, grt1, grt2, data, $
  freq, vchannel_psd,vchannel_deglitch_psd, $
  lfnoise, dc, rbolom, optical, vchannel_psd_optical, avgpsd, $
  file=sav_file

message,/info,'Save file: '+sav_file
message,/info,'PS file: '+ps_file

end
