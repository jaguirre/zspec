;+
;=================================================================
;  Bolomodel
;
;
;  Author: Hien Nguyen
;
;
;  Usage: bolomodel
;
;  Input:
;
;
;  Output:
;
;
;  Edition History:
;
;  12/02/2003   initial test version       H.Nguyen
;
;
;=================================================================
;-

pro Sdc,pps=pps


readcol,'C:\Documents and Settings\Hien\My Documents\DAQ\Data\BZ\badpix.TXT', $
        badpix
nbadpix = n_elements(badpix)
bp = 0
;print,badpix

;readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Data\PMW\Rload.TXT', $
;        pixel,rl1,rl2

;RLOAD = (rl1+rl2)*1e6
RLOAD = 60e6

readcol,'C:\Documents and Settings\Hien\My Documents\DAQ\Analysis\BZ\20050219\RoDelGobeta.TXT', $
        pixel,Ro,Del,Go,beta

Go = Go*1e12

;Ro = 98.8521    ;     55.36
;Del = 17.3290   ;     19.20
;Go =  65.6131   ;4.36
;beta = 1.2876748    ;   1.41

path = 'C:\Documents and Settings\Hien\My Documents\DAQ\Data\BZ\20050219\'
file = '20050219104912'
infile = findfile(path+'/G3/'+file+'*.bin')
print, infile

S_dc = fltarr(96)
vbias = fltarr(96)
Pe = fltarr(96)
V = fltarr(96)
Ib = fltarr(96)
R = fltarr(96)
Vbias = fltarr(96)
peakVbias = findgen(191)
peakSdc = findgen(191)

To  = .100
P_opt = -1e-14*2 + fltarr(101)
Smax = fltarr(n_elements(P_opt))

Tmod = findgen(10000)/100000. + To

device, decompose=0

tek_color
window, 0, ysize=700.0,xsize=1000.0
;device, /close
 if keyword_set(pps) then begin
 ;   device, /close
 ;   set_plot, pdev_save
 ;   x = dialog_message('Plot in file: '+psfilename, /information)

 ; if psfilename NE fpath AND psfilename NE '' then begin
 ;   pdev_save = !d.name
    set_plot, 'PS'   ;'metafile'
   device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
;    device, filename=psfilename
    DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\BZ\20050219\Sdc1.ps'
  endif


!p.multi = 0    ;[0,6,4]
;set_plot, 'PS'     ;'METAFILE'
;DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\Pathfinder\rcold_305mK_20030512.ps'

    blo_noise_read_binary, infile, run_info, sample_info, $
     colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data

i = 0
for jpix = 5,5 do begin       ; run thru pixels
    print, Ro[jpix],Del[jpix],Go[jpix],beta[jpix]

    if jpix eq 6 then jpix = 7
    if jpix eq 9 then jpix = 11
    if jpix eq 89 then jpix = 97
    if jpix eq 121 then jpix = 129
    if jpix eq 153 then jpix = 161

  for jbp = bp,nbadpix-1 do $
     if jpix eq badpix[jbp] then  jpix = jpix+1

    if jpix le 120 then begin

;   blo_noise_read_bfits, infile[j], run_info, sample_info, $
;       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;     paramline=paramline, data=data

; bolo calculation

      bias = data[14,*] - 0.0005    ;10;.000666
      vbolo= data[jpix,*]/375.

      k = WHERE(abs(bias) le 0.010)
      a = linfit(bias[k],vbolo[k])
      voss = a[0]

      vbolo = vbolo-voss

      Rbolo = vbolo/(bias-vbolo)*1.*RLOAD   ;RLOAD[jpix]
      ibolo = vbolo/(Rbolo+1e-9)
      Pbolo = vbolo^2/(Rbolo+1e-9)

    plot, abs(ibolo*1e9)*0,abs(vbolo*1e3)*0,title=jpix, $
          xtitle='Bias (mV)',ytitle='V (mV)'   , xrange=[0,100],yrange=[0,2.5]
;    oplot, abs(ibolo*1e9),abs(vbolo*1e3), color = 4

    for k = 0,n_elements(P_opt)-1 do begin
    Pmod = k*P_opt[k] + Go[jpix]*1e-12/.3^beta[jpix]/(beta[jpix]+1)*(Tmod^(beta[jpix]+1) - To^(beta[jpix]+1))
    Rmod = Ro[jpix]*exp(sqrt(del[jpix]/Tmod))
    imod = sqrt(Pmod/Rmod)
    Vmod = Rmod*imod
    Vbiasmod = (Rmod+RLOAD)*imod

    oplot, vbiasmod*1e3,Vmod*1e3,color=2    ;,psym=5
    error = imod/imod*.001
;    errplot, imod*1e9,vmod*1e3*(1+.001),vmod*1e3*(1-.001),color=3
    Z = deriv(imod,Vmod)
;    plot,Vbiasmod,Z/Rmod,xrange=[0,.1]
    S_dc = (1./(2.*imod)*(Z/Rmod-1)/(Z/(1.*RLOAD)+1))

;    print,k,'  ',P_opt[k]*k

    if k lt n_elements(P_opt)-1 then oplot, Vbiasmod*1e3,(Vmod-S_dc*P_opt[k+1])*1e3,color=5
;    oplot, Vbiasmod*1e3,(Vmod-V_int)*1e3,color=7    ;,psym=1
;    plot,  Vbiasmod*1e3,abs(S_dc),xtitle='Bias (mV)',ytitle='Responsivity V/W'
;    oplot, I1*1e9,(V1-V_cal)*1e3
    kbias = WHERE(abs(Vbiasmod-0.020) lt 0.0005,count)
    if count gt 0 and k eq 0 or k eq 1 or k eq 100 $
        then print,P_opt[k]*k, mean(Vbiasmod[kbias]),1e3*abs(mean(Vmod[kbias]))
;stop

;    if k eq 0 then print, [transpose(vbiasmod), transpose(vmod), $
;                           transpose(imod), transpose(Rmod),     $
;                           transpose(Z), transpose(abs(S_dc)) ]

    endfor

;    plot, abs(P_opt*1e12),(10e-9/Smax)*1e18, title='Amplifier Noise', $
;          xtitle='Total Optical Load (pW)', ytitle='1e-18 W/rtHz'
;stop

;    oplot, imod[kS],Vmod[kS]+P_opt[kS]*(S_dc[kS])
;    print, abs(P_opt*1e12),(10e-9/Smax)*1e18
;    plot,Vbiasmod,Pmod,xrange=[0.,.1]
    endif
;stop
endfor

if keyword_set(pps) then DEVICE, /close
set_plot, 'WIN'

!p.multi = 0

END


