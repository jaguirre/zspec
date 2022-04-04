; +
; Reads a save_spectra file and plots the spectra for each focus
; offset in the file 

; If the correct offsets are not automatically determined, then they
; can be entered as a numeric array, in the same order as the offsets
; were measured in the macro.
; -

pro focus_check,date,obsnum, offsets = offsets,plotme=plotme

date = string(date,format='(I0)')
obsnum = string(obsnum,format='(I03)')

load_plot_colors
;cols = [-1,2,3,4,5]


file = !zspec_data_root+'/ncdf/'+date+'/'+date+$
  '_'+obsnum+'_spectra.sav' 
restore,file

spec = vopt_spectra.in1.nodspec
flags = bolo_flags

if (~keyword_set(offsets)) then begin
    fo = get_focus_offset(rpc_params)
    offsets = fo.focusoff
endif
npoints = n_e(offsets)
offsets_str = string(offsets,format='(F7.3)')

cols = lonarr(npoints)
for i=0,npoints-1 do begin
    cols[i] = !cols.(i+1)
endfor
;[!cols.red,!cols.blue,!cols.green,!cols.magenta,!cols.cyan]

if (n_e(spec[0,*]) ne npoints) then begin
  message,/info,'Observation does not contain the same number of nod positions as pointing offsets.'
  message,/info,'This may not be a focus observation.'
  return
endif


srt = sort(offsets)
ref = srt[npoints/2]
pos = setdifference(lindgen(npoints),[ref])

message,/info,'Referencing to offset '+$
  offsets_str[ref]

ymin = min(spec * (bolo_flags#replicate(1.,npoints)))*1.1
ymax = max(spec * (bolo_flags#replicate(1.,npoints)))*1.1

relspec = spec / (reform(spec[*,ref])#replicate(1.,npoints))

ymin_rel = min(relspec * (bolo_flags#replicate(1.,npoints)))*1.1
ymax_rel = max(relspec * (bolo_flags#replicate(1.,npoints)))*1.1

window,0

plot,spec[*,0],/nodata,/xst,/yst,yr=[ymin,ymax]

for i=0,npoints-1 do begin

    oplot,spec[*,srt[i]],psy=10,col=cols[i]

endfor

legend,box=0,offsets_str[srt],textcol=cols

window,1

plot,relspec[*,0],/nodata,/xst,/yst,yr=[0.9,1.1]

for i=0,npoints-1 do begin

    oplot,relspec[*,srt[i]],psy=10,col=cols[i]

endfor

legend,box=0,offsets_str[srt],textcol=cols

window,2
channels=[30,50,70,100,120,150]

nchan=n_elements(channels)
spec_ave=total(spec(*,srt),1)/160.
cp=poly_fit(offsets(srt),spec_ave,2)
pv=-cp(1)/2./cp(2)
;vline,pv
print,pv
zfit=findgen((max(offsets(srt))-min(offsets(srt)))/0.01)*0.01+min(offsets(srt))
ffit=cp(0)+cp(1)*zfit+cp(2)*zfit^2.


;plot,offsets(srt),spec_ave,/xst,/yst,yr=[ymin,ymax],xtit='Focus
;offset',ytit='Intensity',title='Suggested offset: '+sstr(pv,prec=2)
plot,offsets(srt),spec_ave,/xst,/yst,yr=[ymin,ymax],xtit='Focus offset',ytit='Intensity',title='Suggested offset: '+pv
oplot,zfit,ffit,line=2,color=9
vline,pv,color=9,line=2
for i=0,nchan-1 do oplot,offsets(srt),spec[channels(i),srt],col=cols[i]

legend,box=0,'channel '+sstr(channels),textcol=cols

if keyword_set(plotme) then begin
fileps = !zspec_data_root+'/ncdf/'+date+'/'+date+$
  '_'+obsnum+'_focus_check.ps' 

!p.multi=[0,1,3]
set_plot,'ps'
device,file=fileps,/color,xsize=7.,ysize=10.,/inches


plot,spec[*,0],/nodata,/xst,/yst,yr=[ymin,ymax],xtit='Channel',ytit='Intensity',charsize=1.5
for i=0,npoints-1 do oplot,spec[*,srt[i]],psy=10,col=cols[i]
legend,box=0,offsets_str[srt],textcol=cols,charsize=0.7


plot,relspec[*,0],/nodata,/xst,/yst,yr=[0.9,1.1],xtit='Channel',ytit='Relative Intensity',charsize=1.5
for i=0,npoints-1 do oplot,relspec[*,srt[i]],psy=10,col=cols[i]
legend,box=0,offsets_str[srt],textcol=cols,charsize=0.7


plot,offsets(srt),spec_ave,/xst,/yst,yr=[ymin,ymax],xtit='Focus offset',ytit='Intensity',title='Suggested offset: '+pv,charsize=1.5
oplot,zfit,ffit,line=2,color=9
vline,pv,color=9,line=2
for i=0,nchan-1 do oplot,offsets(srt),spec[channels(i),srt],col=cols[i]
legend,box=0,'channel '+sstr(channels),textcol=cols,charsize=0.7

device,/close
set_plot,'x'

!p.multi=0
endif

end
