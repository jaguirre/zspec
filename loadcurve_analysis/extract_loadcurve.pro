; Version 2010/09/21
; For use at APEX on illapa with bzed version 2.1 (time stamping, one
; file, but can catch a stop.

pro extract_loadcurve, logfile

bolo_flags = get_bolo_flags()

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

;tempconvert(voltage(s), sensor, measurement)

;The first argument can be either a single value or a vector of values and
;will determine the type of the returned value(s), which are temperatures
;in kelvin.  Sensor can be one of 5 strings ('diode', 'roxu01434',
;'cerx31187', 'grt29177', or 'grt29178') and thus it's usage is obvious.
;Measurement can be either 'log' or 'lin'.  If sensor = 'diode',
;measurement is ignorned; otherwise it determines how the voltage(s) are
;scaled to get the resistance of the sensor.


readcol,logfile,format='(A)',data_files,/silent,comment='#'

!p.charsize = 1.

nbox = 10

data = read_bze(data_files[0],nbox,/loadcurve,/be_careful,seq = seq_num)

for i=1,n_e(data_files)-1 do begin
    
    data = [data, read_bze(data_files[i],nbox,/loadcurve,/be_careful,seq = sn)]
    
    seq_num = [[seq_num], [sn]]

endfor

jfet_diode = tempconvert(data.sin[9,1],'diode','')

; Basically, all these thermistors - the GRTs in particular - are of
;                                    such low impedance that the
;                                    linear range is useless.

resistance = data.cos[9,[8,9,10,11]]
cernox = tempconvert(data.sin[9,8],'cerx31187','log')
ruox = tempconvert(data.sin[9,9],'roxu01434','log')
grt1 = tempconvert(data.sin[9,10],'grt29177','log')
grt2 = tempconvert(data.sin[9,11],'grt29178','log')

; NOTE THIS ASSUMES 100 Hz sampling!
t = findgen(n_e(data.cos[0,0]))*.02
; The amount of time the bias is at "zero".  I think I've set this to
; 30 seconds for the current batch of loadcurves, but this should be safe.
t0 = 12.
; Here's the other method of defining where I've set the bias to zero
whzero = lindgen(500)

;x = findgen(n_e(data))
; Aggressively deglitch the bias voltage
x = deglitch(reform(data.cos[0,12]),step=1.d-6)
sortx = sort(x)
xrange = minmax(x[sortx]);[-.2,.2]

temp = strsplit(logfile[0],'/',/extract)
temp = temp[n_e(temp)-1]
file_root = (strsplit(temp,'.',/extract))[0]
temp = strsplit(file_root,'_',/extract)
file_root = 'lc_'+temp[0]+'_'+temp[1]


ps_file = file_root + '.ps'
sav_file = file_root + '.sav'

set_plot,'ps'
device,file=ps_file,/color,/landscape

vchannel_deglitch = dblarr(8,24,n_e(data))
vchannel = dblarr(8,24,n_e(data))
dc_off = dblarr(8,24)
offset = dblarr(8,24)

!p.multi = [0,4,6]

; For our typical 100 Hz sampling, this puts the Nyquist at 5 Hz.
dsfac = 10L

vbias_toplot = x[sortx]
n_toplot = n_e(vbias_toplot)/dsfac
vbias_toplot = $
  rebin((smooth(vbias_toplot,dsfac))[0:n_toplot*dsfac-1],n_toplot,/sample)

for b = 1,8 do begin

    erase

    for i=0,23 do begin

        if (i eq 2) then begin
;            multiplot,[4,6] 
            tit =file_root + string('Box',b,'JFET: ',mean(jfet_diode),$
                         'He3 Box: ',mean(cernox),'GRT 1: ',$
                         mean(grt1),'GRT 2: ',mean(grt2), $
                         format='('+$
                         'A4,I2,"  ",A,F7.1," K, ",A,F7.3," K, ",'+$
                         'A,F7.3," K, ",A,F7.3," K")')
        endif else begin
;            multiplot 
            tit = ''
        endelse
        
        temp = data.cos[b,i]
        vchannel[b-1,i,*] = temp[sortx]
        vchannel_deglitch[b-1,i,*] = deglitch(temp[sortx],step=1.d-4)
; Offset subtraction using the value when bias is set to zero
        dc_off[b-1,i] = mean(data[whzero].cos[b,i])
; Matt's offset subtraction scheme
        offset[b-1,i] = mean(minmax(vchannel_deglitch[b-1,i,*]))

        toplot = vchannel_deglitch[b-1,i,*]-dc_off[b-1,i]
        toplot = $
          rebin((smooth(toplot,dsfac))[0:n_toplot*dsfac-1],n_toplot,/sample)

        if (unused[b-1,i]) then begin
            plot,xrange,[-1,1],tit=tit,/xst,/yst,/nodata,$
              xmargin=[6,2],ymargin=[2,2],charthick=2
            xyouts,0,-.25,'NOT USED',$
              charthick=3,charsize=2,align=0.5
        endif else begin 
            plot,vbias_toplot,toplot,$
              /xst, tit=tit,xr=xrange,xmargin=[6,2],ymargin=[2,2],charthick=2,$
              thick=3
            if (fixed[b-1,i]) then $
              leg_tit = [string(i,format='(I2)'),'FIXED'] $
            else leg_tit = [string(i,format='(I2)')]
            legend,/top,/left,leg_tit,box=0,$
              charthick=2,charsize=0.75
            oplot,xrange,[0,0],line=2
            oplot,[0,0],[-100,100],line=2
        endelse

    endfor

; Time series

    erase

    for i=0,23 do begin

        if (i eq 2) then begin
            tit =file_root + string('Box',b,'JFET: ',mean(jfet_diode),$
                         'He3 Box: ',mean(cernox),'GRT 1: ',$
                                    mean(grt1),'GRT 2: ',mean(grt2), $
                                    format='('+$
                                    'A4,I2,"  ",A,F7.1," K, ",A,F7.3," K, ",'+$
                                    'A,F7.3," K, ",A,F7.3," K")')
        endif else begin
            tit = ''
        endelse

        toplot = data.cos[b,i]
        toplot = $
          rebin((smooth(toplot,dsfac))[0:n_toplot*dsfac-1],n_toplot,/sample)
        
        if (unused[b-1,i]) then begin
            plot,xrange,[-1,1],tit=tit,/xst,/yst,/nodata,$
              xmargin=[6,2],ymargin=[2,2],charthick=2
            xyouts,0,-0.25,'NOT USED',$
              charthick=3,charsize=2,align=0.5
        endif else begin 
            plot,toplot,$
              /xst, tit=tit,xmargin=[6,2],ymargin=[2,2],charthick=2,thick=2,$
              /yno
            if (fixed[b-1,i]) then $
              leg_tit = [string(i,format='(I2)'),'FIXED'] $
            else leg_tit = [string(i,format='(I2)')]
            legend,/top,/left,leg_tit,box=0,$
              charthick=2,charsize=0.75
        endelse
    endfor

endfor

device,/close_file
set_plot,'x'

;multiplot,/reset
cleanplot,/silent

vbias = (reform(data.cos[0,12]))[sortx]
vbias_deglitch = reform(x[sortx])

save,vbias,vbias_deglitch,vchannel,vchannel_deglitch,$
  data, seq_num, $
  dc_off, offset, jfet_diode, ruox, cernox, grt1, grt2, $
  file=sav_file

message,/info,'Save file: '+sav_file
message,/info,'PS file: '+ps_file

end
