;created by LE in April 2008
;
;Modified by JRK 2/24/09: Added a default label_positions_linear and
;label_positions_log to avoid the error if the source name is not part
;of the case syntax.
;
;JRK 3/23/09: print_lines now prints the labels vertically:
;LABEL_POSITIONS_LOG/LINEAR might need to be modified for sources!
;
;JRK 4/16/09: For now sf must be like this (for example):
;   'FSC10214/FSC10214_20090416_1631.sav'
;   But the plotfilename doesn't need directory.

;*************************************************************
;This routine is essentially the same as what used to be at the end of
;uber_spectrum.  Now uber_spectrum only does the coadd and
;calibration, and plot_uber_spectrum is needed to plot the results.
;
;INPUTS
; 'sf' is the name of the savefile (sans directory path) in the
; ncdf/uber_spectra directory that you want to plot
;
; 'plotfilename' is for the output (again, sans directory path).  It will
; save the ps file in the ncdf/uber_spectra directory.
;
; 'twoplot' keyword only plots linear plot (no log) and sensitivity
; (JRK 10/22/10)
;
; 'nolines' keyword means no lines plotted, (JRK 10/22/10)

pro plot_uber_spectrum,sf,plotfilename,twoplot=twoplot,nolines=nolines

sf=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+sf
restore,sf

plotfilename=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+source_name+'/'+plotfilename

hrs=total_n_sec/3600.
hrs=string(hrs,format='(f5.2)')

plottitle=strcompress(source_name)+' Observed by Z-Spec for '+hrs+$
   ' Hrs Integration!CCoadded and calibrated using V_dc curve'

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

;these are default values which can be overridden in case statement
;for sources listed below
   whlow = where(nu ge 220 and nu le 240)
   yrange = $
     [median(uber_spectra.in1.avespec[whlow])*.3,$
      max(uber_spectra.in1.avespec)*1.1]
   yr_linear = yrange
   yr_log = yrange
   linespec=0 ;this decides whether you specify which transitions 
   ;get labeled or if they all get labeled.  The default is false, 
   ;which means the keyword /all_lines is used in the printlines 
   ;routine.  If you specify a lines vector in the case statement 
   ;below, then linespec becomes true and the keyword lines_on is 
   ;used in the printlines command.


   ;These are approximate, probably won't work for all cases.
   ;Note that if you change yr_log or yr_linear viat he case structure
   ;below, you'll likely need to specify these explicitly as well.  
   label_positions_linear=[yrange[1]*.9,yrange[1]*.8,yrange[1]*.7]
   label_positions_log=[yrange[1]*.7,yrange[1]*.3,yrange[1]*.2]

case source_name of 

'APM08279':begin
    yr_linear=[0.005,0.045]
    yr_log=[0.005,0.05]
    yr_sens=[0,4]
    label_positions_log=[0.05,.02,.01]
    label_positions_linear=[.05,.04,.03]
    lines=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1]
end

'Arp193':begin
    yr_linear=[0,0.3]
    yr_log=[0.005,0.6]
    yr_sens=[0,6]
    label_positions_log=[.1,.2,.15]
    label_positions_linear=[.1,.2,.15]
end

'Arp220':begin
   plottitle=strcompress(source_name)+' Observed by Z-Spec Spring 07!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.1,3]            ;Arp220
    yr_linear=[.1,.8]          ;Arp220
    yr_sens=[0,5]              ;Arp220
    label_positions_log=[2.2,1.2,.8] ;for Arp220
    label_positions_linear=[.75,.65,.55]
    lines=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    linespec=1
end

'BLAST164':begin
    yr_linear=[0,0.035]
    yr_log=[0.001,0.1]
    yr_sens=[0,6]
    label_positions_log=[.06,.03,.09]
    label_positions_linear=[.025,.028,.033]
    lines=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'FSC10214':begin
    yr_linear=[-0.02,0.04]
    yr_log=[0.001,.04]
    yr_sens=[0,5]
    label_positions_log=[.03,.01,.02]
    label_positions_linear=[.04,.035,.025]
end

'IRAS10565P2448':begin
    yr_linear=[-0.05,0.22]
    yr_log=[0.005,.3]
    yr_sens=[0,5.5]
    label_positions_log=[.15,0.1,0.2]
    label_positions_linear=[.2,.15,.18]
end

'IRAS17208-0014':begin
   plottitle=strcompress(source_name)+' Observed by Z-Spec Spring 07 & Spring 08!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.01,.7]        ;for IRAS17208-0014
    yr_linear=[0.01,0.2]       ;for IRAS17208-0014
    yr_sens=[0.5,3]           ;for IRAS17208-0014
    label_positions_log=[0.4,0.2,0.1] ;for IRAS17208-0014
    label_positions_linear=[0.16,0.13,0.1 ];for IRAS17208-0014
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'IRC10216':begin
    plottitle=strcompress(source_name)+' Observed by Z-Spec Winter 07!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.5,20]        
    yr_linear=[0,20]      
    yr_sens=[0,15]             
    label_positions_linear=[18,14,10] 
    label_positions_log=[15,10,6] ;for Mrk231
    lines=[1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'HerMES_LockSwire4':begin
;   yr_linear=[0,1.4]
   linespec=1
   
end

'M82_CEN':begin
    yr_linear=[0,1.4]
end

'M82_NE':begin
    yr_linear=[0,1.4]
end

'M82_SW':begin
    yr_linear=[0,1.4]
end

'Mars':begin
    yr_log=[1000,4000];[200,700]             ;Mars
    yr_linear=[1200,4000];[200,700]          ;Mars
    yr_sens=[5,14]              ;Mars
end

'MCOSMOS1':begin
    yr_log=[0.0005,0.05]        ;for MCOSMOS1
    yr_linear=[0.0001,0.03]     ;for MCOSMOS1
    yr_sens=[0.4,1.5]           ;for MCOSMOS1
    label_positions_log=[0.04,0.05,0.062] ;for Arp220
end

'MIPS_J142824':begin
    label_positions_log=[0.035,0.04,0.045]
    label_positions_linear=[0.03,0.032,0.35]
    yr_log=[0.001,0.1]
    yr_linear=[-0.01,0.04]
    yr_sens=[0,3]
end

'Mrk231':begin
    yr_log=[0.01,0.5]           ;for Mrk231
    yr_linear=[0.01,0.1]        ;for Mrk231
    yr_sens=[.5,3]              ;for Mrk231
    label_positions_log=[0.15,0.25,0.4] ;for Mrk231
    label_positions_linear=[0.15,0.25,0.4]
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'NGC1068':begin
    plottitle=strcompress(source_name)+' Observed by Z-Spec January 07!C'+hrs+$
     ' Hrs Integration!CCalibrated using Uranus'
 ;     ' Hrs Integration!CCalibrated using V_dc and 3C279'
    label_positions_linear=[0.97,0.85,0.7] 
    label_positions_log=[5,3,2]
    yr_linear=[0,1]
    yr_sens=[0,5] 
end

'NGC253':begin
    plottitle=strcompress(source_name)+' Observed by Z-Spec Winter 07!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.4,20]        
    yr_linear=[0.2,2.5]      
    yr_sens=[0,15]             
    label_positions_linear=[2,1.5,1] 
    label_positions_log=[10,6,3] ;for Mrk231
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'NGC4038':begin
    yr_linear=[-0.0,0.3]
    label_positions_linear=[yr_linear[1]*.9,yr_linear[1]*.8,yr_linear[1]*.7]
end

'NGC4038N':begin
    yr_linear=[-0.0,0.3]
    label_positions_linear=[yr_linear[1]*.9,yr_linear[1]*.8,yr_linear[1]*.7]
end

'NGC4038C':begin
    yr_linear=[-0.0,0.3]
    label_positions_linear=[yr_linear[1]*.9,yr_linear[1]*.8,yr_linear[1]*.7]
end

'NGC4038S':begin
    yr_linear=[-0.0,0.3]
    label_positions_linear=[yr_linear[1]*.9,yr_linear[1]*.8,yr_linear[1]*.7]
end


'NGC4418':begin
    yr_log=[0.02,.3]            ;NGC4418
    yr_linear=[.02,.2]          ;NGC4418
    yr_sens=[0,3]               ;NGC4418
    label_positions_log=[.13,.17,.22] ;NGC4418
end

'NGC4418ZSPEC':begin
    yr_log=[0.02,.3]            ;NGC4418
    yr_linear=[.02,.2]          ;NGC4418
    yr_sens=[0,3]               ;NGC4418
    label_positions_log=[.13,.17,.22] ;NGC4418
end

'NGC6240':begin
 plottitle=strcompress(source_name)+' Observed by Z-Spec Spring 07!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.007,4.0]          ;NGC6240
    yr_linear=[0,0.2]           ;NGC6240
    yr_sens=[0,5]
    label_positions_log=[0.5,1.0,2] ;NGC6240
    label_positions_linear=[.16,.13,0.1] ;NGC6240
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'NGC891':begin
    plottitle=strcompress(source_name)+' Observed by Z-Spec Winter 07!C'+hrs+$
     ' Hrs Integration!CCoadded and calibrated using V_dc curve'
    yr_log=[0.03,4]           
    yr_linear=[0.0,.6]       
    yr_sens=[0,5]             
    label_positions_linear=[0.4,0.3,0.2]
    label_positions_log=[1.5,1,.6]
    lines=[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    linespec=1
end

'UGC5101':begin
    yr_log=[.002,.12]           ;UGC5101
    yr_linear=[.002,.04]        ;UGC5101
    label_positions_log=[.095,.06,.04]  ;UGC5101
 end

'URANUS':begin
    yr_log=[.002,60]           ;UGC5101
    yr_linear=[.002,60]        ;UGC5101
    label_positions_log=[.095,.06,.04]  ;UGC5101
    label_positions_linear=[.13,.17,.22] ;NGC4418
    yr_sens=[0,5]
end

'VIIZW31':begin
    yr_log=[.001,0.5]          
    yr_linear=[-0.1,0.15]       
    label_positions_log=[.04,.1,.2]
    label_positions_linear=[.09,.05,.12]
    yr_sens=[0,5]               ;NGC4418
 end

else: print,'Using default ranges for plotting....'

endcase


;****************************************************
stop
if ~keyword_set(twoplot) then begin
device,file=plotfilename,/color,/inches,/portrait,xsize=7.5,$
  ysize=8,yoffset=0.5,xoffset=0.5

multiplot,[1,3],/verbose

  plot,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    psym=10,/yno,/yst,ytit='Flux Density [Jy]',$
    xrange=xr,tit=plottitle,/xst,/nodata,$
    thick=4,charsize=1.3,charthick=3,$
    xthick=4,yrange=yr_log,/ylog,ythick=4,$
    ymarg=[20,3]

  oploterror,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    uber_psderror.in1.aveerr,psym=10,col=4,thick=4,errthick=1,$
    errcolor=2

if linespec eq 0 then begin
    if ~keyword_set(nolines) then $
    printlines_uber_spectra,label_positions_log,z,ymin,ymax,/all_lines $
    else printlines_uber_spectra,label_positions_log,z,ymin,ymax,/no_lines
endif else begin
    printlines_uber_spectra,label_positions_log,z,ymin,ymax,$
    lines_on=lines      
endelse

multiplot

endif else begin
device,file=plotfilename,/color,/inches,/landscape,yoffset=0.5,xoffset=0.5

multiplot,[1,2],/verbose
endelse

;now linear plot

  plot,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    psym=10,/yno,/yst,ytit='Flux Density [Jy]',$
    xrange=xr,/xst,/nodata,$
    thick=4,charsize=1.3,charthick=3,$
    xthick=4,yrange=yr_linear,ythick=4

  oploterror,freqid2freq(indgen(160)),uber_psderror.in1.avespec,$
    uber_psderror.in1.aveerr,psym=10,col=4,thick=4,errthick=1,$
    errcolor=2

if linespec eq 0 then begin
    if ~keyword_set(nolines) then $
    printlines_uber_spectra,label_positions_linear,z,yr_linear[0],yr_linear[1],/all_lines $
    else printlines_uber_spectra,label_positions_linear,z,yr_linear[0],yr_linear[1],/no_lines
endif else begin
    printlines_uber_spectra,label_positions_linear,z,yr_linear[0],yr_linear[1],$
    lines_on=lines      
endelse


;plot implied sensitivity
multiplot

plot,freqid2freq(indgen(160)),uber_psderror.in1.aveerr*sqrt(total_n_sec),$
    /yno,ytit=textoidl('Sensitivity [Jy s^{1/2}]'),$
    xrange=xr,/xst,/nodata,$
    thick=4,charsize=1.3,charthick=3,$
    xthick=4,xtit='Detector Channel [GHz]',ythick=4,yrange=yr_sens,/yst

oplot,freqid2freq(indgen(160)),uber_psderror.in1.aveerr*sqrt(total_n_sec),$
  psym=10,col=2,thick=4

multiplot,/reset
device,/close
set_plot,'x',/copy

print,'Postscript plot at: '+plotfilename+'.'

end
