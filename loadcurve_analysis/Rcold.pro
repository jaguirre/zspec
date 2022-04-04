;+
;=================================================================
;  RCOLD
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

pro Rcold,pps=pps


readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\BZ\badpix.TXT', $
        badpix
nbadpix = n_elements(badpix)
bp = 0

if nbadpix gt 0 then print,badpix
;blo_load_data, filename, ctrl, bdata, widg, cch

;readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\PSW\Rload.TXT', $
;        pixel,rl1,rl2

RLOAD = 60e6

path = 'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\BZ\20041007\'

file = '20041007174253'
infile = findfile(path+file+'*.bin')

print, infile

n = n_elements(infile)

Rbol = findgen(191)/findgen(191)
T    = findgen(n)

;RLOAD = 10e6

device, decompose=0

tek_color
;device, /close
 if keyword_set(pps) then begin
 ;   device, /close
 ;   set_plot, pdev_save
 ;   x = dialog_message('Plot in file: '+psfilename, /information)

 ; if psfilename NE fpath AND psfilename NE '' then begin
 ;   pdev_save = !d.name
    set_plot, 'PS'   ;'metafile'
 ;   device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
;    device, filename=psfilename
    DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\PMW\rcold_200407080850.ps'
  endif

window, 0, ysize=700.0,xsize=700.0

!p.multi = 0    ;[0,8,3]
;set_plot, 'PS'     ;'METAFILE'
;DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\Pathfinder\rcold_305mK_20030512.ps'

    blo_noise_read_binary, infile, run_info, sample_info, $
     colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data

      bias = data[31,*]/1.

i = 0
for jpix = 1,24 do begin       ; run thru pixels

    if jpix eq 25 then jpix = 33
    if jpix eq 57 then jpix = 97
    if jpix eq 89 then jpix = 97
    if jpix eq 121 then jpix = 161
    if jpix eq 153 then jpix = 161

  for jbp = bp,nbadpix-1 do $
     if jpix eq badpix[jbp] then  jpix = jpix+1

    if jpix le 184 then begin

;   blo_noise_read_bfits, infile[j], run_info, sample_info, $
;       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;     paramline=paramline, data=data



; temperature conversion

  vbolo= data[jpix,*]/375.

  k = WHERE(abs(bias) le .005)

  m = linfit(bias[k],vbolo[k],/sigma)

if m[1] lt 0. then m[1] = -m[1]

  vbolo = vbolo-m[0]

if i eq 0 then $
  plot,bias,vbolo,title=file,xrange=[-.01,.01],yrange=[-.0004,.0004], $
       xtitle='vbias (V)',ytitle='vbolo (V)',ystyle=3,xstyle=3
  oplot,bias,vbolo,color=i

  Rbol[jpix] = 1.*RLOAD*m[1]/(1.-m[1])

 print, jpix,Rbol[jpix] ;,TK,stdev(data[191,*]*1000.)

endif
i = i+1
endfor

window, 1
  kY = WHERE(Rbol gt 10000. and Rbol lt 1e8)
plothist, Rbol(kY)/1e6,xhist,yhist,bin=3,title=file, $
          xtitle='Resistance (MOhm)'
print, median(Rbol[kY])

if keyword_set(pps) then DEVICE, /close
set_plot, 'WIN'

!p.multi = 0


END
