;+
;=================================================================
;  RVST
;
;
;  Widget Utility to inspect laboratory bolometer data
;
;  Author: Hien Nguyen
;
;
;  Usage: RVST
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

pro RVST,pps=pps


;blo_load_data, filename, ctrl, bdata, widg, cch
readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\BZ\badpix.TXT', $
        badpix
nbadpix = n_elements(badpix)
bp = 0

if nbadpix gt 0 then print, 'Number of bad pixels', nbadpix

readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\BZ\20050219\Temperature_G3.TXT', $
        T

T = T/1000.
;T = T_meas+delT
print, T

;RLOAD = (rl1+rl2)*1e6

RLOAD = 60e6

path = 'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\BZ\'

file = '20050219'
infile = findfile(path+file+'\G3\'+file+'*.bin')

n = n_elements(infile)

Rbol = findgen(n)/findgen(191)
;T    = findgen(n)
P    = findgen(n)
Ro   = fltarr(191)
Delta = fltarr(191)

print, n
print, infile

device, decompose=0

tek_color

!p.multi = 0    ;[0,8,3]

 if keyword_set(pps) then begin
 ;   device, /close
 ;   set_plot, pdev_save
 ;   x = dialog_message('Plot in file: '+psfilename, /information)

 ; if psfilename NE fpath AND psfilename NE '' then begin
 ;   pdev_save = !d.name
    set_plot, 'PS'   ;'metafile'
    device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
;    device, filename=psfilename
    DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\BZ\20050219\rvst_cooldown15.ps'
  endif
;window, 0, ysize=700.0,xsize=700.0

i = 0
for jpix = 1,32 do begin       ; run thru pixels

  for jbp = bp,nbadpix-1 do $
     if jpix eq badpix[jbp] then begin
;          if NOT keyword_set(noplot) then $
        ;plot,[1,8],[0.,5e-11],/nodata, $
        ;title=jpix,xtitle='R (100 kOhm)',ytitle='power'
        print,jpix,'    0. ','0.'
        jpix = jpix+1
        bp = bp+1
     endif

;    if jpix eq 6 then jpix = 7
;    if jpix eq 14 then jpix = 21
;    if jpix eq 89 then jpix = 97
;    if jpix eq 121 then jpix = 129
;    if jpix eq 153 then jpix = 161

  if jpix le 184 then $

    for j = 0,n-1 do begin      ; run thru temperatures

;    if j eq 4 then j = 7
;    if j eq 8 then j = 10
;    if j eq 11 then j = 13

;   blo_noise_read_bfits, infile[j], run_info, sample_info, $
;       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;     paramline=paramline, data=data

    blo_noise_read_binary, infile[j], run_info, sample_info, $
     colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data

      bias = data[14,*]/1. -.0005;+offset[j]
      vbolo= data[jpix,*]/375.

; temperature conversion

;if jpix eq 5 then print, T[j]

  k = WHERE(abs(bias) le .01)

;if j ge 2 then k = WHERE(abs(bias) le 0.010)

;plot, bias[k],vbolo[k]

  m = linfit(bias[k],vbolo[k])

if m[1] lt 0. then m[1] = -m[1]

;print, m

 ; oplot, bias[k],bias[k]*m[1] + m[0],color=3
  Rbol[j] = 1.*RLOAD*m[1]/(1.-m[1])

;stop
;print, Rbol[j]
    endfor

;stop

  kY = WHERE(Rbol gt 100.)
;  plot, T(kY),Rbol(kY),psym=5

  Y = alog(Rbol[kY])
  X = 1./sqrt(T[kY])
;  print, 'ln of R', Y
;  print, '1/sqrt(T)', X
;  stop

if i eq 0 then $
  plot, X,Y,psym=5,title=file, yrange=[14.3,15.3],xrange=[2.35,2.55], $
     xtitle='1/sqrt(T)',ytitle='ln(R)',ystyle=3
  oplot,X,Y,psym=5,color=i+1
  a = linfit(X,Y)
  oplot, X,a[0]+X*a[1],color=i+1
  Ro[jpix] = exp(a[0])
  Delta[jpix] = a[1]^2
  ;print, bias,vbolo[115]
 print, jpix, Ro[jpix], Delta[jpix]

;if i eq 0 then stop
i = i+1
;stop
endfor

livepixel = WHERE(Ro gt 0. and Ro lt 1e4)

;window, 1
!p.multi = [0,2,1]

plothist,Ro[livepixel],xhist,yhist, bin=10,$
        yrange=[0,40],xtitle = 'Ro',title=file
plothist,Delta[livepixel], yrange=[0,40],xtitle = 'Delta',title=file

print,median(Ro[livepixel]),median(Delta[livepixel])

if keyword_set(pps) then device,/close
set_plot, 'WIN'
!p.multi = 0

END
