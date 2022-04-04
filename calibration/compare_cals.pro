pro compare_cals,newcal,onech=onech,fname=fname

;___________________________________________________________
;
;Created LE 2007-11-15
;
;This routine restores the calibration observation data from Spring 07
;along with their line fits and overplots a new planet calibration
;observation from the current run.
;
;Setting keyword onech equal to a channel number will plot in an
;x-window the results for just that channel.  Otherwise it will
;generate a postscript of all 160 channels.
;
;
; Modified by MB 2008 April 12 to save out the calibration discrepancy as a
; save file to be used in the coadditions.
; Note that the newcal argument is the result of the flux_calibration_oneobs
; function
; ALSO modified the intput the fname to be a string which does not include the
; ps on the end.   I suggest simply using YYYYMMDD_OBS.
; The output ps file will be this + _calcomp.ps
; The sav file with the 160 correction values will be _calcor.sav
;
; Futher modified by LE 2008 April 17
; Calibration files have been updated for spring 07 (incorporating
; beam size and Mars temperature corrections).  References to the
; spring07 linear fits have been corrected to refer to the updated
; version.
;
;_________________________________________________________________

restore,!zspec_pipeline_root+'/calibration/calibration_obs_spring07.sav'
restore,$
  !zspec_pipeline_root+'/calibration/calibration_obs_spring07_fitparams.sav'

if ~keyword_set(onech) then begin
        file=!zspec_pipeline_root+'/calibration/'+fname+'_calcomp.ps'
        set_plot,'ps'
        device,/landscape,filename=file,/inches,/color
        discrepancy=fltarr(160)
endif

for ch=0,159 do begin

 if keyword_set(onech) then ch=onech 

 case newcal.source of 

    0:begin  ;MARS
        planetflag=0
        pagetitle=$
          'Comparing New Calibration Obs (Red) with !CSpring 2007 Mars Observations'
        goodmars=plotmars(where(cal_total[ch,plotmars] gt 0))
        x=[min(vbolo_quad_total[goodmars,ch]),$
           max(vbolo_quad_total[goodmars,ch])*1.1] 
        plot,vbolo_quad_total[goodmars,ch],$
          cal_total[ch,goodmars],/yno,/yst,/nodata,$
          ytit='Flux Calibration [V/Jy]',xtit='DC Voltage [V]',$
          title=pagetitle,xrange=x,/xst,$
          xthick=2,ythick=2.,charsize=1.5,$
          yr=[0,max(cal_total[ch,goodmars])*1.2],$
          ymarg=[4,4],xmarg=[12,2]        ;plot mars & its fit
          oploterror,vbolo_quad_total[goodmars,ch],$
            cal_total[ch,goodmars],err_total[ch,goodmars],$
            psym=4
          oplot,x,(fitpars[ch,planetflag,0]+fitpars[ch,planetflag,1]*x),$
            thick=2,col=4
      end
     1:begin  ;URANUS
         planetflag=1
         pagetitle='Compare with Spring 2007 Uranus Observations'
         gooduranus=ploturanus(where(cal_total[ch,ploturanus] gt 0))
         x=[min(vbolo_quad_total[gooduranus,ch]),$
           max(vbolo_quad_total[gooduranus,ch])] 
        plot,vbolo_quad_total[gooduranus,ch],$
          cal_total[ch,gooduranus],/yno,/yst,/nodata,$
          ytit='Flux Calibration [V/Jy]',xtit='DC Voltage [V]',$
          title=pagetitle,xrange=x,/xst,$
          xthick=2,ythick=2.,charsize=1.5       
        ;plot uranus & its fit
          oploterror,vbolo_quad_total[gooduranus,ch],$
            cal_total[ch,gooduranus],err_total[ch,gooduranus],$
            psym=4
          oplot,x,(fitpars[ch,planetflag,0]+fitpars[ch,planetflag,1]*x),$
            thick=2,col=4
      end
     3:begin  ;NEPTUNE
         planetflag=2
         pagetitle='Compare with Spring 2007 Neptune Observations'
         goodnep=plotnep(where(cal_total[ch,plotnep] gt 0))
         x=[min(vbolo_quad_total[goodnep,ch]),$
           max(vbolo_quad_total[goodnep,ch])] 
        plot,vbolo_quad_total[goodnep,ch],$
          cal_total[ch,goodnep],/yno,/yst,/nodata,$
          ytit='Flux Calibration [V/Jy]',xtit='DC Voltage [V]',$
          title=pagetitle,xrange=x,/xst,$
          xthick=2,ythick=2.,charsize=1.5       
        ;plot neptune & its fit
          oploterror,vbolo_quad_total[goodnep,ch],$
            cal_total[ch,goodnep],err_total[ch,goodnep],$
            psym=4
          oplot,x,(fitpars[ch,planetflag,0]+fitpars[ch,planetflag,1]*x),$
            thick=2,col=4
      end
  endcase

  oploterror,newcal.dc[*,ch],newcal.cal[ch,*],newcal.calerr[ch,*],$
    col=2,psym=2

  legend,/top,/right,box=0,$
    ['New Cal: '+string(mean(newcal.cal[ch,*]),format='(G8.3)'),$
     'Ratio:   '+$
     string(mean(newcal.cal[ch,*])/$
            (fitpars[ch,0,0]+fitpars[ch,0,1]*mean(newcal.dc[*,ch])),$
            format='(F8.2)')],$
    charthick=2,charsize=1.5

  legend,/top,/left,box=0,$
    ['Channel'+strcompress(ch)],$
    charthick=2,charsize=1.5

;  xyouts,0.25,0.85,'Channel'+strcompress(ch),/normal,charthick=2,$
;    charsize=1.5

  if keyword_set(onech) then ch=159

endfor

if ~keyword_set(onech) then begin
    device,/close
    set_plot,'x'
    
    for ch=0,160-1 do begin
        discrepancy[ch]=$
          mean(newcal.cal[ch,*])/(fitpars[ch,planetflag,0]+$
                                  fitpars[ch,planetflag,1]*mean(newcal.dc[*,ch]))
    end
    save,discrepancy,filename=!zspec_pipeline_root+$
      '/calibration/cal_corr_files/'+fname+'_calcor.sav'



endif

;stop
end
