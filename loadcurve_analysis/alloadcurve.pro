;+
;=================================================================
;  IVCURVE
;
;
;  Widget Utility to inspect laboratory bolometer data
;
;  Author: Hien Nguyen
;
;
;  Usage: ivcurve
;
;  Input:
;
;
;  Output:
;
;
;  Edition History:
;
;  03/10/2002   initial test version       B.Schulz
;
;
;=================================================================
;-

pro alloadcurve,pps=pps

path = 'C:\Documents and Settings\Hien\My Documents\DAQ\Data\BZ\20050219\G3\'
infile = findfile(path+'20050219104912*.bin')
print, infile

n = n_elements(infile)
;device,/close
device, decompose=0

tek_color

ndx = 2
ndy = 2
!p.multi=[0,ndx,ndy]

RLOAD = 30e6
  if keyword_set(pps) then begin
;    device, /close
    set_plot, 'PS'
    device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
    DEVICE, FILENAME='C:\Documents and Settings\Hien\My Documents\DAQ\Analysis\PSW\alloadcurve.ps'
  endif

for j = 0, n-1 do begin          ; run thru temperature files

print, infile[j]
window, 0, xsize=1000, ysize=700, title=filename, xpos=10, ypos=10

     blo_noise_read_binary, infile[j], run_info, sample_info, $
     colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
     paramline=paramline, data=data

      bias = (data[14,*]+0.000)/1.
      bias = bias - .0005  ;001

i=0
for jpix = 5,11 do begin          ; run thru pixels

 ;     blo_noise_read_bfits, infile[j], run_info, sample_info, $
 ;      colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
 ;      paramline=paramline, data=data

if jpix eq 6 then jpix = 7
if jpix eq 9 then jpix = 11

      vbolo= data[jpix,*]/375.
;      if i eq 0 then plot, data[191,*],yrange=[-.5,.5]
;      oplot, data[191,*]

       k = WHERE(abs(bias) le 0.003)
       a = linfit(bias[k],vbolo[k])
       voss = a[0]

       vbolo = vbolo-voss

       Rbolo = vbolo/(bias-vbolo)*2.*RLOAD
       ibolo = vbolo/(Rbolo+1e-9)
       Pbolo = vbolo^2/(Rbolo+1e-9)

 ; if i eq 0 then $
    plot, abs(bias),abs(vbolo),xrange=[0,.2],yrange=[0,.0020], $
          title=jpix,xtitle='vbias',ytitle='vbolo',ystyle=3
;    oplot, abs(bias),abs(vbolo),color=i+3

     i=i+1

  endfor
  i = 0

    count = 0
    kmax = WHERE(vbolo eq max(vbolo) and vbolo lt 0.0097, count)
;    if count gt 0 then print, jpix, bias(kmax)*1e3,vbolo(kmax)*1e3

stop
endfor
if keyword_set(pps) then device,/close
set_plot, 'WIN'

!p.multi=0
END
