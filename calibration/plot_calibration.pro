;written by LE April 2008
;
;08/30/10 - KSS - Added option to plot fit to all data
;12/17/12 - KSS - Modified rms shadding.

pro plot_calibration,calsavefile

restore,!zspec_pipeline_root+'/calibration/'+calsavefile

calfitfile=change_suffix(calsavefile,'_fitparams.sav')

restore,!zspec_pipeline_root+'/calibration/'+calfitfile

outputname=change_suffix(calsavefile,'_plot.ps')
;_________________________________________________________________

set_plot,'ps'
!p.charsize=2.
!p.charthick=4.
!p.thick=4.
loadct, 39

filename=!zspec_pipeline_root+'/calibration/'+outputname

device,file=filename,/color,/landscape,/inches

for ch=0,159 do begin

    pagetitle=outputname+$
      '  Freq ID '+strcompress(ch)+' ='+string(freqid2freq(ch),format='(F5.1)')+'GHz!C'

    gooddata=where(cal_total[ch,*] gt 0)

    if mars_obs eq 1 then begin
    goodmars=plotmars(where(cal_total[ch,plotmars] gt 0))
    dum=-1
    endif
    
    if uranus_obs eq 1 then begin
dum=where(cal_total[ch,ploturanus] gt 0)
    if dum(0) ne -1 then gooduranus=ploturanus(dum)
    endif
    
    if neptune_obs eq 1 then begin
dum=where(cal_total[ch,plotnep] gt 0)
    if dum(0) ne -1 then goodnep=plotnep(dum)
endif


if gooddata(0) ne -1 then begin 
        x=[min(vbolo_quad_total[gooddata,ch]),$
           max(vbolo_quad_total[gooddata,ch])] 

        plot,vbolo_quad_total[gooddata,ch],$
          cal_total[ch,gooddata],/yno,/yst,/nodata,$
          ytit='V/Jy',xtit=textoidl('V_{DC}'),$
          title=pagetitle,xrange=x,/xst,$
          xthick=4,ythick=4.,charsize=1.5, position=[0.15,0.12,0.95,0.90]
        ;plot combined fit? RMS first
        if keyword_set(fitpars_all) then begin
            y = (fitpars_all[ch,0]+fitpars_all[ch,1]*x)
            y2p_u = y*(1.0+rms_dev_all[ch])
            whb = where(y2p_u gt !y.crange[1], nb)
            if (nb gt 0) then y2p_u[whb] = !y.crange[1]
            y2p_l = reverse(y*(1.0-rms_dev_all[ch]))
            whb = where(y2p_l lt !y.crange[0], nb)
            if (nb gt 0) then y2p_l[whb] = !y.crange[0]
            
            polyfill, [x, reverse(x), x[0]], $
              [y2p_u, y2p_l, y2p_u[0]], $
              col=190
            ;polyfill, [x, reverse(x)], $
            ;  [y*(1.0+rms_dev_all[ch]), reverse(y*(1.0-rms_dev_all[ch]))], $
            ;  col=190
        endif
    endif
        ;plot mars & its fit

        if mars_obs eq 1 then begin

          oploterror,vbolo_quad_total[goodmars,ch],$
            cal_total[ch,goodmars],err_total[ch,goodmars],$
            col=250,psym=6

          oplot,x,(fitpars[ch,0,0]+fitpars[ch,0,1]*x),$
            thick=4,col=250

        endif
        
        ;plot uranus & its fit

        if uranus_obs eq 1 and dum(0) ne -1 then begin

          oploterror,vbolo_quad_total[gooduranus,ch],$
            cal_total[ch,gooduranus],err_total[ch,gooduranus],$
            col=50,psym=5

          oplot,x,(fitpars[ch,1,0]+fitpars[ch,1,1]*x),$
            thick=4,col=50

         endif

       ;plot neptune & its fit

        if neptune_obs eq 1 and dum(0) ne -1 then begin

          oploterror,vbolo_quad_total[goodnep,ch],$
            cal_total[ch,goodnep],err_total[ch,goodnep],$
            col=150,psym=4

          oplot,x,(fitpars[ch,2,0]+fitpars[ch,2,1]*x),$
            thick=4,col=150

        endif

        ;plot combined fit? best-fit second
        if keyword_set(fitpars_all) then begin
            oplot, x, (fitpars_all[ch,0]+fitpars_all[ch,1]*x), $
              thick=4, col=0, linestyle=2
        endif

       ;print out chi-squared values and labels
        
          if mars_obs eq 1 then begin
              marslabel=textoidl('\chi^2_{Mars} =')
              xyouts,0.6,0.42,marslabel+$
                strcompress(chi_sq_vals[ch,0]),$
                col=250,/normal
              xyouts,0.6,0.37,'RMS frac dev = '+$
                strcompress(string(rms_dev[ch,0],format='(f4.2)')),$
                col=250,/normal
              xyouts,0.2,0.85,'MARS',/normal,col=250
          endif

          if uranus_obs eq 1 then begin
              uralabel=textoidl('\chi^2_{Uranus}=')
              xyouts,0.6,0.3,uralabel+$
                strcompress(chi_sq_vals[ch,1]),$
                col=50,/normal              
              xyouts,0.6,0.25,'RMS frac dev = '+$
                strcompress(string(rms_dev[ch,1],format='(f4.2)')),$
                col=50,/normal
              xyouts,0.2,0.77,'URANUS',/normal,col=50
          endif

          if neptune_obs eq 1 then begin
              neplabel=textoidl('\chi^2_{Neptune}=')
              xyouts,0.6,0.18,neplabel+$
                strcompress(chi_sq_vals[ch,2]),$
                col=150,/normal
              xyouts,0.6,0.13,'RMS frac dev = '+$
                strcompress(string(rms_dev[ch,2],format='(f4.2)')),$
                col=150,/normal
              xyouts,0.2,0.69,'NEPTUNE',/normal,col=150
          endif

          if keyword_set(fitpars_all) then begin
              alllabel=textoidl('\chi^2_{All}=')
              xyouts,0.6,0.54,alllabel+$
                strcompress(chi_sq_vals_all[ch]),$
                col=0,/normal
              xyouts,0.6,0.49,'RMS frac dev = '+$
                strcompress(string(rms_dev_all[ch],format='(f4.2)')),$
                col=0,/normal
              xyouts,0.2,0.61,'ALL',/normal,col=0
          endif
              

endfor ;loop over all bolometers

device,/close
set_plot,'x'

pdffile=change_suffix(filename,'.pdf')

spawn,'ps2pdf '+filename


end
