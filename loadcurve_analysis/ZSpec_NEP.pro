
pro     ZSpec_NEP,pps=pps,noplot=noplot

;
;     by Hien Nguyen, Apr 7, 2001
;     by Hien Nguyen, Aug 12, 2003
;     by H. Nguyen, Oct 7, 2003
;     by H. Nguyen, Dec 9, 2003
;     by H. Nguyen, Apr 28, 2004
;
; some fundamental constants,

PI  = 3.14159
kB  = double(1.38e-23)   ;   J/K, Boltzman constant
c   = double(3e8)      ;   m/s, Speed of Light
h   = double(6.63e-34)      ;   J/s, Planck constant
sigma_SB = 5.67e-8          ;   J/K^4/m^2/s, Stefan-Boltzman constant
Jy  = double(1e-26)         ;   J/s/m^2/Hz, Jansky

; some experimental condition

Ts = [ 4.19744,5.27460,20., 30., 40., 50., 60., 70. ]        ; PLW - Jan 09, 2005

n = n_elements(Ts)

inband_power = fltarr(n)
NEP = fltarr(n)

device, decompose=0

tek_color

  if keyword_set(pps) then begin
;    device, /close
 ;   set_plot, pdev_save
 ;   x = dialog_message('Plot in file: '+psfilename, /information)

 ; if psfilename NE fpath AND psfilename NE '' then begin
 ;   pdev_save = !d.name
    set_plot, 'ps'
    device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
;    device, filename=psfilename
    DEVICE, FILENAME='C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\PLW\PLWpassband.ps'
  endif

print, 'Souce Temperature (K),', Ts

;readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\PLW-FS\PFIL4L.TXT', $
;        waveno1,PFIL4L,skipline=2

;readcol,'C:\Documents and Settings\Hien Trong Nguyen\My Documents\DAQ\Analysis\PLW-FS\EDGE_B499.TXT', $
;        waveno2,B499,skipline=2

window, 0

;plot,waveno1*30,PFIL4L,xtitle='GHz',ytitle='Transmission', $
;     title='PFM PLW Filters', xrange=[200,1200],yrange=[0,1]
;oplot,waveno2*30,B499,color=5

;int_res = interpol(PFIL4L,waveno1,waveno2,/quadratic)

;oplot, waveno2*30,int_res,color=4

;PLWFIL = int_res*B499

;oplot, waveno2*30,PLWFIL,color=3

nufilter = findgen(400)*1e9 +1e9    ; Hz

eta = fltarr(400) + .80        ; transmission

plot, nufilter/1e9, eta, yrange=[0.,2.], xtitle='GHz'
feedhorn_diam = 353e-6
;nu_cutoff = 1.02*c/(feedhorn_diam*1.706)
nu_cutoff = 195e9

PLWLOWF = nu_cutoff*[1,1]
PLWHIGHF = PLWLOWF+1.5e11    ;c/430.8e-6*[1,1]
Y1 = [0,1]
oplot, PLWLOWF/1e9,Y1,color=2
oplot, PLWHIGHF/1e9,Y1,color=2

k = WHERE(nufilter le nu_cutoff)
eta[k] = 0.
m = WHERE(nufilter gt nu_cutoff+1.5e09)
eta[m] = 0.


oplot, nufilter/1e9,eta,color=7

;stop
;print, transpose(eta)

window, 1
jplot = 0
for i = n-1, 0, -1 do begin

    x = h*nufilter/(kB*Ts[i])

    y = x/(exp(x)-1)

    if jplot eq 0 then plot, nufilter/1e9,y,yrange=[0,1.],xrange=[180,380]
    oplot, nufilter/1e9, y, color=i+3

    inband_y = y*eta

    oplot, nufilter/1e9,inband_y,color=i+3

    inband_power[i] = 2.*kB^2/h*Ts[i]^2*INT_TABULATED(x,inband_y)
   ; print, i,Ts[i],inband_power[i]

    y_poisson = x^2/(exp(x)-1)*eta
    y_bose   = x^2/(exp(x)-1)^2*eta

    nep_poisson2 = 4.*kB^3/h*Ts[i]^3*INT_TABULATED(x,y_poisson)
    nep_bose2  = 4.*kB^3/h*Ts[i]^3*INT_TABULATED(x,y_bose)

    NEP[i] = sqrt(nep_poisson2 + nep_bose2)

    print, i,Ts[i],inband_power[i],NEP[i],sqrt(nep_poisson2)

    jplot = i+1
;stop
endfor
oplot, PLWLOWF/1e9,Y1,color=2
oplot, PLWHIGHF/1e9,Y1,color=2

window, 3
plot, Ts,inband_power

;print, 'Inband Power (W)', inband_power
print, 'Inband Power difference (pW)', (inband_power-inband_power[0])*1e12

;print, format="(f6.3,f6.3,f6.3,f6.3,f6.3,f6.3,f6.3)",waveno1,f476, $
;       waveno2,f488, waveno3, B514, SSWFIL

if keyword_set(pps) then device,/close

set_plot, 'WIN'

end