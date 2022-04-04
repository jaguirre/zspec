pro     gbeta,pps=pps

common amoeb, T, P, Tc

readcol,'C:\Documents and Settings\Hien\My Documents\DAQ\Analysis\BZ\20050219\RoDel.TXT', $
        pixel,Ro,Del

Go=dblarr(31) + 6e-11
Beta=dblarr(31)+1.50d0

path = 'C:\Documents and Settings\Hien\My Documents\DAQ\Data\BZ\'

file = '20050219'
infile = findfile(path+file+'\G3\'+file+'104912*.bin')

n = n_elements(infile)

device, decompose=0

tek_color

window, 0, ysize=700.0,xsize=700.0
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
    DEVICE, FILENAME='C:\Documents and Settings\Hien\My Documents\DAQ\Analysis\BZ\20050219\PvsT.ps'
  endif

  blo_noise_read_binary, infile, run_info, sample_info, $
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data

  bias = data[14,*] -.0005

  RLOAD = 60e6

for channel=5, 11 do begin

  if channel eq 6 then channel = 7
  if channel eq 9 then channel = 11

  k = WHERE(abs(bias) le 0.01)

  vbolo= data[channel,*]/375.
  vbolo[0:7] = vbolo[8]

  a = linfit(bias[k],vbolo[k])
  voss = a[0]

  vbolo = vbolo-voss

  Rbolo = vbolo/(bias-vbolo)*1.*RLOAD
  ibolo = vbolo/Rbolo
  Pbolo = vbolo^2/Rbolo

  T = Del[channel]/[alog(Rbolo/Ro[channel])]^2
  Tc = .1576
  P = Pbolo

  ;plotting
  plot, T,P,psym=3,title=channel, $
        xtitle="Temperature (K)",ytitle="Power (W)"
  oplot, T,P,color=4,psym=3

  ;stop
        a0 = Go[channel]
        a1=Beta[channel]+1.d0

        a = [a0, a1]


        R = AMOEBA(1.0e-5, SCALE=[1e-10,100.], P0 = a, FUNCTION_VALUE=fval, $
           function_name='bolodark_amoebafunc_rvs')
        if n_elements(r) EQ 2 then a = r

        Go[channel]=a[0]
        Beta[channel]=a[1]-1.d0

        Pmod = Go[channel]/.3^Beta[channel]/(Beta[channel]+1)* $
               (T^(Beta[channel]+1) - Tc^(Beta[channel]+1))
    oplot, T,Pmod,color=2


    print, channel, Ro[channel],Del[channel],Go[channel],Beta[channel]

    ENDFOR

if keyword_set(pps) then DEVICE, /close
set_plot, 'WIN'

!p.multi = 0

END