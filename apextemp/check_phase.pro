; Plot up the chopper phase for a list of scans

function check_phase,scans,datestr

nparams=N_params()
if nparams EQ 1 then datestr=''

loadct,39

phArr=dblarr(160,size(scans,/dim))
timeArr=dblarr(size(scans,/dim))

for j=1,n_elements(scans) do begin
    ; Use run_zapex to ensure all scans are present before running.
    ;zapex,scans[j-1],1,2
    fname='/home/zspec/data/observations/*/APEX-'+strtrim(scans[j-1],2)+'-2010*E-086.A-0793A-2010_chopphase.sav'
    file=file_search(fname)
    if file(0) ne '' then restore,fname else begin
        zapex,scans[j-1],1,2
        restore,fname
        endelse
    phArr(*,j-1)=rel_phase[0,*]
    timeArr(j-1)=mean(nc_ticks)
end
timeArr-=34 ; convert to UTC since midnight
timeArr/=3600
timeArr(where(timearr GT 15))-=24

PLOT_CHS=transpose(findgen(8)*5+80) ; Channels to plot
phaseChannels=phArr(PLOT_CHS,*)

plot,scans-79000,phaseChannels(0,*)/!dtor,psym=1,color=255,$
  yrange=[-180,180],title=datestr,xtit='Scan Number - 79000',ytit='Chopper Phase'
for j=1,n_elements(PLOT_CHS)-1 do begin
    col=floor(j*254/(n_elements(PLOT_CHS)-1))
    oplot,scans-79000,phaseChannels(j,*)/!dtor,psym=1,color=col
end

;plot,timeArr,phaseChannels(0,*)/!dtor,psym=1,color=255,$
;  yrange=[-180,180],title=datestr,xtit='UT Hour',ytit='Chopper Phase'
;for j=1,n_elements(PLOT_CHS)-1 do begin
;    col=floor(j*254/(n_elements(PLOT_CHS)-1))
;    oplot,timeArr,phaseChannels(j,*)/!dtor,psym=1,color=col
;end

phSz=size(phaseChannels,/dim) & phSz(0)+=2
pha=dblarr(phSz) 
pha[0,*]=timearr
pha[1,*]=scans
pha[2:phSz(0)-1,*]=phaseChannels
return,pha
end
