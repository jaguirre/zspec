; Modified 2006/08/19  JA to work with new data taking script
; take_noise and also the new bzed

pro extract_noise_new, logfile, yrange = yrange

bad_channels = intarr(10,24)
;bad_channels[1,0] = 1

; nV / rtHz
if not keyword_set(yrange) then yrange = [1.d-10,1.d-6]*1.d9

readcol,logfile,format='(A)',data_files,/silent,comment='#'

!p.charsize = 1.

nbox = 10

; In the new bzed, only the first line after the commented "PASSED"
; statements is needed

data = read_bze(data_files[2],nbox,seq=seq_num,sec=seconds)

sample_interval = find_sample_interval(seconds)

print,'Sample interval is '+string(sample_interval,format='(F6.2)')+' sec'

; File names
temp = strsplit(logfile[0],'/',/extract)
temp = temp[n_e(temp)-1]
file_root = (strsplit(temp,'.',/extract))[0]
temp = strsplit(file_root,'_',/extract)
file_root = 'noise_'+temp[0]+'_'+temp[1]

ps_file = file_root + '.ps'
sav_file = file_root + '.sav'

; Set up the PSD stuff
; Measured AC gain at 100 Hz bias frequency.
gain = 150. ;200./sqrt(2.)
navg = 1024L
rload = 30.d6

vchannel_deglitch = dblarr(8,24,n_e(data))
vchannel = dblarr(8,24,n_e(data))

set_plot,'ps'
device,file=ps_file,/color,/landscape

freq = (psd(fltarr(navg),samp=sample_interval,avg=navg)).freq
xrange = minmax(freq)

vbias = (reform(sqrt(data.cos[0,12]^2 + data.sin[0,12]^2)))
vbias_deglitch = deglitch(vbias,step=1.d-2)
vbias_mean = mean(vbias_deglitch)

vchannel_deglitch_psd = dblarr(8,24,navg/2+1)
vchannel_psd = dblarr(8,24,navg/2+1)

for b = 1,8 do begin

    erase
    cleanplot,/sil

    for i=0,23 do begin

        if (i eq 0) then begin
            multiplot,[4,6] 
        endif else begin
            multiplot 
        endelse

        case i of 
            3 : tit = file_root
            0 : tit = 'Box '+strcompress(b,/rem)
            else : tit = ''
        endcase 

        vchannel[b-1,i,*] = sqrt(data.cos[b,i]^2 + data.sin[b,i]^2)/gain
        vchannel_deglitch[b-1,i,*] = $
          deglitch(reform(vchannel[b-1,i,*]),step=1.d-4)

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

        plot_io,freq,vchannel_psd[b-1,i,*]*1.d9,$
          /xst, xr=xrange, tit=tit, yst=yst, yr=yrange, yticks=ytcks
        oplot,freq,vchannel_deglitch_psd[b-1,i,*]*1.d9,col=2

        dc = mean(vchannel_deglitch[b-1,i,*])
        rbolo = 2.*rload*(dc/vbias_mean)/(1.-dc/vbias_mean)
        
        whlf = where(freq ge 1 and freq le 5)
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
                 '"1-5 Hz Noise: ",F8.1," ",A,"!C",'+$
                 '"DC mean:      ",F8.2," nV !C",'+$
                 '"Rbolo:        ",F8.3," ",A)'),$
          charsize=.7

        oplot,[1,5],[1,1]*lfnoise,col=3,thick=5

        if (bad_channels[b,i]) then begin
            oplot,[xrange[0],xrange[1]],[yrange[0],yrange[1]],thick=2
            oplot,[xrange[0],xrange[1]],[yrange[1],yrange[0]],thick=2
        endif

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

resistance = data.cos[9,[8,9,10,11]]
jfet_diode = tempconvert(data.sin[9,1],'diode','')
cernox = tempconvert(data.sin[9,8],'cerx31187','log')
ruox = tempconvert(data.sin[9,9],'roxu01434','log')
grt1 = tempconvert(data.sin[9,10],'grt29177','log')
grt2 = tempconvert(data.sin[9,11],'grt29178','log')

; Including seconds may cause a problem if there's no timestamp ...
save,vbias,vbias_deglitch,vchannel,vchannel_deglitch,$
  jfet_diode, cernox,ruox,grt1,grt2,resistance, seconds, data, $
  freq, vchannel_psd,vchannel_deglitch_psd, $
  file=sav_file

message,/info,'Save file: '+sav_file
message,/info,'PS file: '+ps_file

end
