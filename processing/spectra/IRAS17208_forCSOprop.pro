
sf=!zspec_data_root+'/ncdf/uber_spectra/IRAS17208-0014_20080528_1749.sav'
restore,sf

plotfilename='IRAS17208_forCSOprop.eps'
  
hrs=total_n_sec/3600.
hrs=string(hrs,format='(f5.2)')

;_________________________________________________________________________
;make ps plots

!p.thick=2
!p.charthick=2
!x.thick=2
!y.thick=2

set_plot,'ps',/copy
xr=[180,310]
ymin=0.001
ymax=20
nu = freqid2freq()


   plottitle=strcompress(source_name)+' Observed by Z-Spec Spring 07 & Spring 08!C'+hrs+$
     ' Hrs Integration'
    yr_log=[0.01,.7]        ;for IRAS17208-0014
    yr_linear=[0.01,0.2]       ;for IRAS17208-0014
    yr_sens=[0.5,3]           ;for IRAS17208-0014
    label_positions_log=[0.4,0.2,0.1] ;for IRAS17208-0014
    label_positions_linear=[0.16,0.13,0.1 ];for IRAS17208-0014
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1


;****************************************************

cleanplot

device,/encapsulated,file=plotfilename,/color,/inches

  plot,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    psym=10,/yno,/yst,ytit='Flux Density [Jy]',$
    xrange=xr,/xst,/nodata,$
    thick=4,charsize=1.3,charthick=3,$
    xthick=4,yrange=yr_linear,ythick=4,xtit=textoidl('\nu [GHz]'),$
    tit=plottitle

  oploterror,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    uber_psderror.in1.aveerr,psym=10,col=4,thick=4,errthick=1,$
    errcolor=2

    printlines_uber_spectra,label_positions_linear,z,yr_linear[0],yr_linear[1],$
    lines_on=lines      


device,/close
set_plot,'x',/copy

print,'Postscript plot at: '+plotfilename+'.'

end
